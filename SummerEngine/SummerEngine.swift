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
    - Animation Groups (Part of the main texture)
    - Documentation
    - Modify Textures
    - Opacity Transforms
 
 Cool Features:
    - Single File Tileset Loading (GIF and Tileset Image)
    - Combined Transforms
    - Buttons and Better Events
    - Batch Tileset/Animation loading
    - Make Object Constructors Dedicated (so overriding works well)
 
 Just in case I forget:
    - Set Object/Transform space to 0 on delete in SummerFeatures
    - Merge unit and display detection functions (should be same unit)
 
 Fixes:
    - Mouse flipping should not be using Units (exclusively, mostly Amps) and should be applied to x and y
    - Brief nil texture animation bug on start
 */

/// Stores instance resources and hosts methods for creating objects.
public class SummerEngine : NSObject, MTKViewDelegate {
    internal var program: SummerProgram
    /// Engine settings, for quickly changing how the engine behaves.
    public var settings: SummerSettings
    /// Engine features, for checking if your application is compatible with this instance.
    public let features: SummerFeatures
    private let view: SummerView
    
    internal let device: MTLDevice!
    internal let commandQueue: MTLCommandQueue!
    
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
    
    internal var objectDisposables = Queue<SummerObject>()
    internal var transformDisposables = Queue<SummerTransform>()
    
    /// By default, an object uses this draw.
    public private(set) var globalDraw: SummerDraw!
    /// By default, an object uses this transform.
    public private(set) var globalTransform: SummerTransform!
    
    private let mapPipelineState: MTLRenderPipelineState
    internal var maps = [SummerMap]()
    internal let draws = LinkedList<SummerDraw>()
    
    public var beforeUpdateEvents = [() -> Void]()
    public var afterUpdateEvents = [() -> Void]()
    
    private var isAborting = false
    /// Halts the engine and the program.
    public func abort() {
        settings.messageHandler?(.aborting)
        isAborting = true
    }
    
    internal func addObjectModify(_ object: SummerObject) { objectModifyQueue.append(object) }
    internal func addTransformModify(_ transform: SummerTransform) { transformModifyQueue.append(transform) }
    
    internal func clearObjectSpace() -> Bool {
        if objectDisposables.isEmpty { return false }
        
        objectDisposables.dequeue()?.delete()
        
        return true
    }
    
    internal func clearTransformSpace() -> Bool {
        if transformDisposables.isEmpty { return false }
        
        transformDisposables.dequeue()?.delete()
        
        return true
    }
    
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
        for event in beforeUpdateEvents { event() }
        program.update()
        dequeueModifies()
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!) {
                renderEncoder.setFragmentSamplerState(samplerState, index: 0)
                if maps.count > 0 {
                    renderEncoder.setRenderPipelineState(mapPipelineState)
                    renderEncoder.setVertexBuffer(transformBuffer, offset: 0, index: 2)
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
                for draw in draws { draw.addDraws(encoder: renderEncoder) }
                
                renderEncoder.endEncoding()
            }
            
            commandBuffer.present(view.currentDrawable!)
            commandBuffer.commit()
        }
        for event in afterUpdateEvents { event() }
    }
    
    /// Changes the engine setting's display size to the view's size in points.
    public func autoDetectDisplaySize() {
        settings.displayWidth = Int(view.drawableSize.width) / 2
        settings.displayHeight = Int(view.drawableSize.height) / 2
    }
    
    /// Changes the engine setting's unit size to the view's size in points.
    public func autoDetectUnitSize() {
        settings.horizontalUnit = 1 / (Float(view.drawableSize.width) / 2)
        settings.verticalUnit = 1 / (Float(view.drawableSize.height) / 2)
    }
    
    /// Deletes all draws that do not contain an object.
    public func deleteEmptyDraws() {
        for i in 0 ..< draws.count {
            if draws[i].isEmpty() {
                draws.remove(at: i)
            }
        }
    }
    
    /// Removes all disposable objects and transforms.
    public func clearDisposables() {
        for _ in 0 ..< objectDisposables.count { objectDisposables.dequeue()?.delete() }
        for _ in 0 ..< transformDisposables.count { transformDisposables.dequeue()?.delete() }
    }
    
    /// Frees all allocations. All objects, textures, draws, etc. may be overwritten.
    public func freeAllocations() {
        objectAllocationData = [Bool](repeating: false, count: features.maxObjects)
        transformAllocationData = [Bool](repeating: false, count: features.maxTransforms + 1)
        textureAllocationData = [Bool](repeating: false,
                                       count: features.textureAllocWidth * features.textureAllocHeight)
        
        globalDraw = SummerDraw(nil)
        globalTransform = SummerTransform(self)
        draws.removeAll()
        maps.removeAll()
        clearDisposables()
    }
    
    /// Frees all allocations except for certain objects passed in arrays.
    ///
    /// - Parameters:
    ///   - keepObjects: The objects to keep.
    ///   - keepTextures: Any extra textures to keep.
    ///   - keepDraws: Any extra draws to keep.
    ///   - keepTransforms: Any extra transforms to keep.
    public func freeAllocations(keepObjects: [SummerObject],
                                keepTextures: [SummerTexture] = [],
                                keepDraws: [SummerDraw] = [],
                                keepTransforms: [SummerTransform] = []) {
        freeAllocations()
        
        for texture in keepTextures { texture.allocate() }
        for object in keepObjects {
            if object.isDisposable { continue }
            object.allocate()
            object.texture.allocate()
            // Kou-chan will remember this.
            if object.transform.isGlobal {
                object.transform = globalTransform
            } else {
                object.transform.allocate()
            }
            if object.draw.isGlobal {
                globalDraw.addObject(object)
            } else {
                draws.append(object.draw)
            }
        }
        for draw in keepDraws { draws.append(draw) }
        for transform in keepTransforms { transform.allocate() }
    }
    
    /// Changes the current program.
    ///
    /// - Parameters:
    ///   - newProgram: The new program.
    ///   - keepResources: If true, no resources will be deleted.
    /// - Returns: The last program.
    @discardableResult public func swapPrograms(_ newProgram: SummerProgram, keepResources: Bool = false) -> SummerProgram {
        let oldProgram = program
        
        if !keepResources { freeAllocations() }
        
        if features.clearSettingsOnProgramSwap {
            settings = SummerSettings()
            autoDetectDisplaySize()
            autoDetectUnitSize()
        }
        
        program = newProgram
        settings.messageHandler?(.swapping)
        program.setup(engine: self)
        
        return oldProgram
    }
    
    /// Changes the current program.
    ///
    /// - Parameters:
    ///   - newProgram: The new program.
    ///   - keepObjects: Any objects to be kept after the swap.
    ///   - keepTextures: Any textures to be kept after the swap.
    ///   - keepDraws: Any draws to be kept after the swap.
    ///   - keepTransforms: Any transforms to be kept after the swap.
    /// - Returns: The last program.
    @discardableResult public func swapPrograms(_ newProgram: SummerProgram,
                                                keepObjects: [SummerObject],
                                                keepTextures: [SummerTexture] = [],
                                                keepDraws: [SummerDraw] = [],
                                                keepTransforms: [SummerTransform] = []) -> SummerProgram {
        freeAllocations(keepObjects: keepObjects,
                        keepTextures: keepTextures,
                        keepDraws: keepDraws,
                        keepTransforms: keepTransforms)
        
        return swapPrograms(newProgram, keepResources: true)
    }
    
    private var keyStates = [SummerInputState](repeating: .released, count: 0xFF)
    
    /// Gets the key state for a specific key.
    ///
    /// - Parameter key: The key to be checked.
    /// - Returns: The state for the key.
    public func getKeyState(key: SummerKey) -> SummerInputState {
        if keyStates.count <= key.rawValue { return .released }
        return keyStates[Int(key.rawValue)]
    }
    
    /// Checks if a key is currently in its pressed state.
    ///
    /// - Parameter key: The key to be checked.
    /// - Returns: True if the key is being pressed.
    public func isKeyPressed(key: SummerKey) -> Bool {
        return getKeyState(key: key) == .pressed
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
    
    /// Engine constructor.
    ///
    /// - Parameters:
    ///   - program: The program to be run.
    ///   - nView: The summer view to be drawn to.
    ///   - features: A features structure for extra control over memory.
    ///   - settings: A settings structure for extra control over behavior.
    /// - Throws:
    ///   - .couldNotCreateDevice: If the platform is unable to create a metal context.
    ///   - .couldNotCreateResources: If the platform is unable to create important resources.
    ///   - .noDefaultLibrary: If the engine cannot find a default library.
    ///   - .viewInUse: If the view is already being used by another SummerEngine instance.
    public init(_ program: SummerProgram,
                view nView: SummerView,
                features: SummerFeatures = SummerFeatures(),
                settings: SummerSettings = SummerSettings()) throws {
        self.program = program
        self.features = features
        self.settings = settings
        view = nView
        
        settings.messageHandler?(.starting)
        
        device = MTLCreateSystemDefaultDevice()
        if device == nil { throw SummerError.cannotCreateDevice }
        view.device = device
        
        commandQueue = device.makeCommandQueue()
        if commandQueue == nil { throw SummerError.cannotCreateResources }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        let mapPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        var library: MTLLibrary
        
        if features.useDefaultLibrary {
            if let lib = device.makeDefaultLibrary() { library = lib }
            else { throw SummerError.couldNotFindLibrary }
        } else {
            guard let libraryPath = Bundle.main.path(forResource: "SummerShaders", ofType: "metallib")
                else { throw SummerError.couldNotFindLibrary }
            if let lib = try? device.makeLibrary(filepath: libraryPath) { library = lib }
            else { throw SummerError.couldNotFindLibrary }
        }
        
        let vertexShader = library.makeFunction(name: "vertexShader")
        let mapVertexShader = library.makeFunction(name: "mapVertexShader")
        let textureShader = library.makeFunction(name: "textureShader")
        
        pipelineDescriptor.vertexFunction = vertexShader
        pipelineDescriptor.fragmentFunction = textureShader
        mapPipelineDescriptor.vertexFunction = mapVertexShader
        mapPipelineDescriptor.fragmentFunction = textureShader
        
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
        catch { throw SummerError.cannotCreateResources }
        do { mapPipelineState = try device.makeRenderPipelineState(descriptor: mapPipelineDescriptor) }
        catch { throw SummerError.cannotCreateResources }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest
        samplerDescriptor.rAddressMode = .repeat
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        objectBuffer = device.makeBuffer(length: SummerObject.size * features.maxObjects)
        if objectBuffer == nil { throw SummerError.cannotCreateResources }
        
        transformBuffer = device.makeBuffer(length: SummerTransform.size * features.maxTransforms + 1,
                                            options: features.staticTransform ? .storageModeManaged : .storageModeShared)
        if transformBuffer == nil { throw SummerError.cannotCreateResources }
        
        pivotBuffer = device.makeBuffer(length: features.maxObjects * SummerTransform.pivotSize,
                                        options: features.staticPivot ? .storageModeManaged : .storageModeShared)
        if pivotBuffer == nil { throw SummerError.cannotCreateResources }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: features.textureAllocWidth, height: features.textureAllocHeight,
            mipmapped: false)
        
        texture = device.makeTexture(descriptor: textureDescriptor)
        if texture == nil { throw SummerError.cannotCreateResources }
        
        objectAllocationData = [Bool](repeating: false, count: features.maxObjects)
        transformAllocationData = [Bool](repeating: false, count: features.maxTransforms + 1)
        textureAllocationData = [Bool](repeating: false,
                                       count: features.textureAllocWidth * features.textureAllocHeight)
        
        super.init()
        
        globalDraw = SummerDraw(nil, isGlobal: true)
        globalTransform = SummerTransform(self, isGlobal: true)
        
        if !view.setEngine(engine: self) { throw SummerError.viewInUse }
        
        autoDetectDisplaySize()
        autoDetectUnitSize()
        
        program.setup(engine: self)
        settings.messageHandler?(.looping)
    }
}
