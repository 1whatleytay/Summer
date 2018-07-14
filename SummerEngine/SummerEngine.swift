//
//  SummerEngine.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-16.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Cocoa
import Foundation

import Metal
import MetalKit

/*
 Finished things:
    - Key Input
    - Mouse Input (clicks)
    - Mouse Movement
    - Listen Keys (check if key is pressed)
    - Asset Loading
    - Draw Groups (to replace maxDraw)
    - Matrix Movement
    - Offsets
    - Key Codes in Package (from Carbon)
    - Swap Programs
    - Tilesets (Seperate texture)
    - Maps (Tiled maps w/ tileset)
    - Default Settings by Controller
    - Visibility
    - Multiple Maps and Transform Maps
 
 Things I gave up on:
    - Mouse Capture
 
 Cool Features:
    - Buttons
    - Animation Groups (Part of the main texture)
    - Documentation
    - Modify Textures
    - Single File Tileset Loading
    - Combined Transforms
 
 Fixes:
    - Mouse flipping should not be using Units (exclusively, mostly Amps) and should be applied to x and y
 */

public class SummerEngine : NSObject, MTKViewDelegate {
    internal var program: SummerProgram
    public var settings: SummerSettings
    public let features: SummerFeatures
    private let view: SummerView
    
    internal let device: MTLDevice!
    private let commandQueue: MTLCommandQueue!
    
    internal let objectBuffer: MTLBuffer!
    internal let transformBuffer: MTLBuffer!
    internal let pivotBuffer: MTLBuffer!
    internal let texture: MTLTexture!
    
    private let pipelineState: MTLRenderPipelineState
    private let samplerState: MTLSamplerState
    
    internal var objectAllocationData: [Bool]
    internal var transformAllocationData: [Bool]
    internal var textureAllocationData: [Bool]
    
    private var objectModifyQueue = [SummerObject]()
    private var transformModifyQueue = [SummerTransform]()
    
    public private(set) var globalDraw: SummerDraw!
    public private(set) var globalTransform: SummerTransform!
    internal let objectDraws = LinkedList<SummerDraw>()
    
    private let mapPipelineState: MTLRenderPipelineState
    internal var maps = [SummerMap]()
    
    private var isAborting = false
    public func abort() {
        program.message(message: .aborting)
        isAborting = true
    }
    
    internal func addObjectModify(_ object: SummerObject) { objectModifyQueue.append(object) }
    internal func addTransformModify(_ transform: SummerTransform) { transformModifyQueue.append(transform) }
    
    private func dequeueObjectModifies() {
        for object in objectModifyQueue {
            object.save()
            object.modified = false
        }
        
        objectModifyQueue.removeAll(keepingCapacity: !settings.conserveModifyMemory)
    }
    
    private func dequeueTransformModifies() {
        for transform in transformModifyQueue {
            transform.save()
            transform.modified = false
        }
        
        transformModifyQueue.removeAll(keepingCapacity: !settings.conserveModifyMemory)
    }
    
    private func dequeueModifies() {
        dequeueObjectModifies()
        dequeueTransformModifies()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    public func draw(in view: MTKView) { step() }
    
    private func step() {
        if isAborting {
            view.delegate = nil
            return
        }
        program.update()
        dequeueModifies()
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!) {
                renderEncoder.setFragmentSamplerState(samplerState, index: 0)
                if maps.count > 0 {
                    renderEncoder.setRenderPipelineState(mapPipelineState)
                    for map in maps {
                        map.setResources(renderEncoder)
                        map.addDraws(renderEncoder)
                    }
                }
                
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setVertexBuffer(objectBuffer, offset: 0, index: 0)
                renderEncoder.setVertexBuffer(transformBuffer, offset: 0, index: 1)
                renderEncoder.setVertexBuffer(pivotBuffer, offset: 0, index: 2)
                renderEncoder.setFragmentTexture(texture, index: 0)
                globalDraw.addDraws(encoder: renderEncoder)
                for draw in objectDraws { draw.addDraws(encoder: renderEncoder) }
                
                renderEncoder.endEncoding()
            }
            
            commandBuffer.present(view.currentDrawable!)
            commandBuffer.commit()
        }
    }
    
    public func autoDetectDisplaySize() {
        settings.displayWidth = Int(view.drawableSize.width) / 2
        settings.displayHeight = Int(view.drawableSize.height) / 2
    }
    
    public func autoDetectUnitSize() {
        settings.horizontalUnit = 1 / (Float(view.drawableSize.width) / 2)
        settings.verticalUnit = 1 / (Float(view.drawableSize.height) / 2)
    }
    
    public func deleteEmptyDraws() {
        for (i, draw) in objectDraws.enumerated() {
            if draw.isEmpty() {
                objectDraws.remove(at: i)
            }
        }
    }
    
    private func freeAllocations() {
        objectAllocationData = [Bool](repeating: false, count: features.maxObjects)
        transformAllocationData = [Bool](repeating: false, count: features.maxTransforms)
        textureAllocationData = [Bool](repeating: false,
                                       count: features.textureAllocWidth * features.textureAllocHeight)
        
        globalDraw = SummerDraw(nil)
        globalTransform = SummerTransform(self)
        objectDraws.removeAll()
    }
    
    @discardableResult public func swapPrograms(_ newProgram: SummerProgram, keepResources: Bool = false) -> SummerProgram {
        let oldProgram = program
        
        if !keepResources { freeAllocations() }
        
        if features.clearSettingsOnProgramSwap { settings = SummerSettings() }
        
        program = newProgram
        program.message(message: .swapping)
        program.setup(engine: self)
        
        return oldProgram
    }
    
    @discardableResult public func swapPrograms(_ newProgram: SummerProgram,
                                                keepObjects: [SummerObject],
                                                keepTextures: [SummerTexture] = [],
                                                keepDraws: [SummerDraw] = [],
                                                keepTransforms: [SummerTransform] = []) -> SummerProgram {
        freeAllocations()
        
        for texture in keepTextures { texture.allocate() }
        for object in keepObjects {
            object.allocate()
            object.texture.allocate()
            // Kou-chan will remember this.
            if object.transform.isGlobal {
                object.setTransform(to: globalTransform)
            } else {
                object.transform.allocate()
            }
            if object.draw.isGlobal {
                globalDraw.addObject(object: object)
            } else {
                objectDraws.append(object.draw)
            }
        }
        for draw in keepDraws { objectDraws.append(draw) }
        for transform in keepTransforms { transform.allocate() }
        
        return swapPrograms(newProgram, keepResources: true)
    }
    
    private var keyStates = [SummerInputState](repeating: .released, count: 0xFF)
    
    public func getKeyState(key: UInt16) -> SummerInputState {
        if keyStates.count <= key { return .released }
        return keyStates[Int(key)]
    }
    
    public func isKeyPressed(key: SummerKey) -> Bool {
        return getKeyState(key: key.rawValue) == .pressed
    }
    
    internal func keyChanged(key: UInt16, characters: String?, state: SummerInputState) {
        keyStates[Int(key)] = state
        program.key(key: SummerKey(rawValue: key) ?? .vkUnknown, characters: characters, state: state)
    }
    
    internal func mouseButtonChanged(button: SummerMouseButton,
                                     x: Double, y: Double,
                                     state: SummerInputState) {
        program.mouse(button: button,
                      x: x,
                      y: Double(settings.displayHeight) - y,
                      state: state)
    }
    
    internal func mouseMoved(x: Double, y: Double) {
        program.mouse(button: .movement,
                      x: x,
                      y: Double(settings.displayHeight) - y,
                      state: .movement)
    }
    
    public func makeObject(
        x: Float, y: Float,
        width: Float, height: Float,
        texture: SummerTexture,
        isVisible: Bool = true) -> SummerObject {
        return SummerObject(self,
                            x: x, y: y,
                            width: width, height: height,
                            texture: texture,
                            isVisible: isVisible)
    }
    
    public func makeTexture(width: Int, height: Int, data: [UInt8]) -> SummerTexture {
        return SummerTexture(self, width: width, height: height, data: data)
    }
    
    public func makeTexture(width: Int, height: Int, data: [Float]) -> SummerTexture {
        return SummerTexture(self, width: width, height: height, data: data)
    }
    
    public func makeTexture(fromFile file: String,
                            _ location: SummerFileLocation = .inFolder) -> SummerTexture? {
        return SummerTexture(self, fromFile: file, location)
    }
    
    public func makeTexture(fromFile file: String) -> SummerTexture? {
        return SummerTexture(self, fromFile: file)
    }
    
    public func makeColor(red: Float, green: Float, blue: Float, alpha: Float) -> SummerTexture {
        return SummerTexture(self, width: 1, height: 1, data: [red, green, blue, alpha])
    }
    
    public func makeDraw() -> SummerDraw { return SummerDraw(self) }
    public func makeTransform() -> SummerTransform { return SummerTransform(self) }
    
    public func makeTileset(tileWidth: Int, tileHeight: Int, data: [[UInt8]]) -> SummerTileset {
        return SummerTileset(self, tileWidth: tileWidth, tileHeight: tileHeight, data: data)
    }
    
    public func makeTileset(tileWidth: Int, tileHeight: Int, data: [[Float]]) -> SummerTileset {
        return SummerTileset(self, tileWidth: tileWidth, tileHeight: tileHeight, data: data)
    }
    
    public func makeTileset(fromFiles files: [String], _ location: SummerFileLocation) -> SummerTileset? {
        return SummerTileset(self, fromFiles: files, location)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [UInt32],
                        tileset: SummerTileset,
                        unitX: Float, unitY: Float,
                        mapType: SummerMapType = .staticMap) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height,
                         data: data,
                         tileset: tileset,
                         unitX: unitX, unitY: unitY,
                         mapType: mapType)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [UInt32],
                        tileset: SummerTileset,
                        mapType: SummerMapType = .staticMap) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height,
                         data: data,
                         tileset: tileset,
                         mapType: mapType)
    }
    
    public init(_ program: SummerProgram,
                view nView: SummerView,
                features: SummerFeatures = SummerFeatures(),
                settings: SummerSettings = SummerSettings()) throws {
        self.program = program
        self.features = features
        self.settings = settings
        view = nView
        
        program.message(message: .starting)
        
        device = MTLCreateSystemDefaultDevice()
        if device == nil { throw SummerError.cannotCreateDevice }
        view.device = device
        
        commandQueue = device.makeCommandQueue()
        if commandQueue == nil { throw SummerError.cannotCreateQueue }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let mapPipelineDescriptor = MTLRenderPipelineDescriptor()
        if let library = device.makeDefaultLibrary() {
            let vertexShader = library.makeFunction(name: "vertexShader")
            let mapVertexShader = library.makeFunction(name: "mapVertexShader")
            let textureShader = library.makeFunction(name: "textureShader")
            
            pipelineDescriptor.vertexFunction = vertexShader
            pipelineDescriptor.fragmentFunction = textureShader
            mapPipelineDescriptor.vertexFunction = mapVertexShader
            mapPipelineDescriptor.fragmentFunction = textureShader
        } else { throw SummerError.noDefaultLibrary }
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        mapPipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        if features.transparency {
            pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        }
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 2
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 4
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do { pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor) }
        catch { throw SummerError.cannotCreatePipelineState }
        do { mapPipelineState = try device.makeRenderPipelineState(descriptor: mapPipelineDescriptor) }
        catch { throw SummerError.cannotCreateMapPipelineState }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest
        samplerDescriptor.rAddressMode = .repeat
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        objectBuffer = device.makeBuffer(length: SummerObject.size * features.maxObjects)
        if objectBuffer == nil { throw SummerError.cannotCreateObjectBuffer }
        
        transformBuffer = device.makeBuffer(length: SummerTransform.size * features.maxTransforms,
                                            options: features.staticTransform ? .storageModeManaged : .storageModeShared)
        if transformBuffer == nil { throw SummerError.cannotCreateTransformBuffer }
        
        pivotBuffer = device.makeBuffer(length: features.maxObjects * SummerTransform.pivotSize,
                                        options: features.staticPivot ? .storageModeManaged : .storageModeShared)
        if pivotBuffer == nil { throw SummerError.cannotCreatePivotBuffer }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: features.textureAllocWidth, height: features.textureAllocHeight,
            mipmapped: false)
        
        texture = device.makeTexture(descriptor: textureDescriptor)
        if texture == nil { throw SummerError.cannotCreateTexture }
        
        objectAllocationData = [Bool](repeating: false, count: features.maxObjects)
        transformAllocationData = [Bool](repeating: false, count: features.maxTransforms)
        textureAllocationData = [Bool](repeating: false,
                                       count: features.textureAllocWidth * features.textureAllocHeight)
        
        super.init()
        
        globalDraw = SummerDraw(nil, isGlobal: true)
        globalTransform = SummerTransform(self, isGlobal: true)
        
        if !view.setEngine(engine: self) { throw SummerError.viewInUse }
        
        autoDetectDisplaySize()
        autoDetectUnitSize()
        
        program.setup(engine: self)
        program.message(message: .looping)
    }
}
