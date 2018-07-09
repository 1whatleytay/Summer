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
 
 Things I gave up on:
    - Mouse Capture
 
 SEEarly4 ✔
 
 Cool Features:
    - Buttons
    - Tilesets (Seperate texture)
    - Animation Groups (Part of the main texture)
    - Maps (Tiled maps w/ tileset)
    - Swap Programs
    - Key Codes in Package (from Carbon)
    - Documentation
 
 Fixes:
    - Mouse flipping should not be using Units (exclusively, mostly Amps) and should be applied to x and y
    - Screen size parameter to program info should be added (setScreensize() for units too?)
 */
public class SummerEngine : NSObject, MTKViewDelegate {
    internal let program: SummerProgram
    internal let programInfo: SummerInfo
    private let view: SummerView
    
    private let device: MTLDevice!
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
    
    public var globalDraw: SummerDraw!
    public var globalTransform: SummerTransform!
    internal let objectDraws = LinkedList<SummerDraw>()
    
    private var isAborting = false
    public func abort() { isAborting = true }
    
    internal func addObjectModify(_ object: SummerObject) { objectModifyQueue.append(object) }
    internal func addTransformModify(_ transform: SummerTransform) { transformModifyQueue.append(transform) }
    
    private func dequeueObjectModifies() {
        for object in objectModifyQueue {
            object.save()
            object.modified = false
        }
        
        objectModifyQueue.removeAll(keepingCapacity: true)
    }
    
    private func dequeueTransformModifies() {
        for transform in transformModifyQueue {
            transform.save()
            transform.modified = false
        }
        
        transformModifyQueue.removeAll(keepingCapacity: true)
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
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setVertexBuffer(objectBuffer, offset: 0, index: 0)
                renderEncoder.setVertexBuffer(transformBuffer, offset: 0, index: 1)
                renderEncoder.setVertexBuffer(pivotBuffer, offset: 0, index: 2)
                renderEncoder.setFragmentTexture(texture, index: 0)
                renderEncoder.setFragmentSamplerState(samplerState, index: 0)
                globalDraw.addDraws(encoder: renderEncoder)
                for draw in objectDraws { draw.addDraws(encoder: renderEncoder) }
                renderEncoder.endEncoding()
            }
            commandBuffer.present(view.currentDrawable!)
            commandBuffer.commit()
        }
    }
    
    private var keyStates = [SummerInputState](repeating: .released, count: 400)
    
    public func getKeyState(key: UInt16) -> SummerInputState {
        if keyStates.count <= key { return .released }
        return keyStates[Int(key)]
    }
    
    public func isKeyPressed(key: UInt16) -> Bool {
        return getKeyState(key: key) == .pressed
    }
    
    internal func keyChanged(key: UInt16, characters: String?, state: SummerInputState) {
        keyStates[Int(key)] = state
        program.key(key: key, characters: characters, state: state)
    }
    
    internal func mouseButtonChanged(button: SummerMouseButton,
                                     x: Double, y: Double,
                                     state: SummerInputState) {
        program.mouse(button: button,
                      x: x,
                      y: 1 / Double(programInfo.verticalUnit) - y,
                      state: state)
    }
    
    internal func mouseMoved(x: Double, y: Double) {
        program.mouse(button: .movement,
                      x: x,
                      y: 1 / Double(programInfo.verticalUnit) - y,
                      state: .movement)
    }
    
    public func makeObject(
        x: Float, y: Float,
        width: Float, height: Float,
        texture: SummerTexture) -> SummerObject {
        return SummerObject(self,
                            x: x, y: y,
                            width: width, height: height,
                            texture: texture)
    }
    
    public func makeTexture(width: Int, height: Int, data: [UInt8]) -> SummerTexture {
        return SummerTexture(self, width: width, height: height, data: data)
    }
    
    public func makeTexture(width: Int, height: Int, data: [Float]) -> SummerTexture {
        return SummerTexture(self, width: width, height: height, data: data)
    }
    
    public func makeTexture(fromFile file: String,
                            _ location: SummerTexture.SummerFileLocation = .inFolder) -> SummerTexture? {
        return SummerTexture(self, fromFile: file, location)
    }
    
    public func makeColor(red: Float, green: Float, blue: Float, alpha: Float) -> SummerTexture {
        return SummerTexture(self, width: 1, height: 1, data: [red, green, blue, alpha])
    }
    
    public func makeDraw() -> SummerDraw { return SummerDraw(self) }
    public func makeTransform() -> SummerTransform { return SummerTransform(self) }
    
    public init(_ nProgram: SummerProgram, view nView: SummerView) throws {
        program = nProgram
        programInfo = program.info()
        view = nView
        
        program.message(message: .starting)
        
        device = MTLCreateSystemDefaultDevice()
        if device == nil { throw SummerError.cannotCreateDevice }
        view.device = device
        
        commandQueue = device.makeCommandQueue()
        if commandQueue == nil { throw SummerError.cannotCreateQueue }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        if let library = device.makeDefaultLibrary() {
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")!
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "textureShader")!
        } else { throw SummerError.noDefaultLibrary }
        pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        if programInfo.transparency {
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
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .nearest
        samplerDescriptor.magFilter = .nearest
        samplerDescriptor.rAddressMode = .repeat
        samplerDescriptor.sAddressMode = .repeat
        samplerDescriptor.tAddressMode = .repeat
        samplerState = device.makeSamplerState(descriptor: samplerDescriptor)!
        
        objectBuffer = device.makeBuffer(length: SummerObject.size * programInfo.maxObjects)
        if objectBuffer == nil { throw SummerError.cannotCreateObjectBuffer }
        transformBuffer = device.makeBuffer(length: SummerTransform.size * programInfo.maxTransforms)
        if transformBuffer == nil { throw SummerError.cannotCreateTransformBuffer }
        pivotBuffer = device.makeBuffer(length: programInfo.maxObjects * SummerTransform.pivotSize)
        if pivotBuffer == nil { throw SummerError.cannotCreatePivotBuffer }
        objectAllocationData = [Bool](repeating: false, count: programInfo.maxObjects)
        transformAllocationData = [Bool](repeating: false, count: programInfo.maxTransforms)
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: programInfo.textureAllocWidth, height: programInfo.textureAllocHeight,
            mipmapped: false)
        
        texture = device.makeTexture(descriptor: textureDescriptor)
        textureAllocationData = [Bool](repeating: false, count: programInfo.textureAllocWidth * programInfo.textureAllocHeight)
        if texture == nil { throw SummerError.cannotCreateTexture }
        
        globalDraw = SummerDraw(nil)
        
        super.init()
        
        globalTransform = makeTransform()
        
        if !view.setEngine(engine: self) { throw SummerError.viewInUse }
        
        program.setup(engine: self)
        program.message(message: .loop)
    }
}
