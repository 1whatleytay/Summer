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
 Things that have been finished:
    - Key Input
    - Mouse Input (clicks)
    - Mouse Movement
    - Listen Keys (check if key is pressed)
 
 Things to add before catching up to SEEarly4:
    - Mouse Capture
    - Asset Loading
 
 Cool Features:
    - Buttons
    - Tilesets (Seperate texture)
    - Animation Groups (Part of the main texture)
    - Maps (Tiled maps w/ tileset)
    - Draw Groups (to replace maxDraw)
    - Matrix Movement
    - Offsets
 
 Fixes:
    - Mouse flipping should not be using Units (exclusively, mostly Amps) and should be applied to x and y
    - Screen size parameter to program info should be added (setScreensize() for units too?)
 */
public class SummerEngine : NSObject, MTKViewDelegate {
    internal static var currentEngine: SummerEngine?
    
    internal let program: SummerProgram
    internal let programInfo: SummerInfo
    private let view: SummerView
    
    private let device: MTLDevice!
    private let commandQueue: MTLCommandQueue!
    internal let objectBuffer: MTLBuffer!
    internal let texture: MTLTexture!
    
    private let pipelineState: MTLRenderPipelineState
    private let samplerState: MTLSamplerState
    
    internal var objectAllocationData: [Bool]
    internal var textureAllocationData: [Bool]
    private var objectMaxDraw = 0
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    public func draw(in view: MTKView) { render() }
    
    public func setAsCurrentEngine() { SummerEngine.currentEngine = self }
    
    internal func calculateMaxRenderDraw() {
        var maxDrawIndex = objectAllocationData.count
        for (index, alloc) in objectAllocationData.reversed().enumerated() {
            if alloc {
                maxDrawIndex = index
                break
            }
        }
        
        print("Max Render Value: \(objectAllocationData.count - maxDrawIndex)")
        
        objectMaxDraw = objectAllocationData.count - maxDrawIndex
    }
    
    private func render() {
        program.update()
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!) {
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setVertexBuffer(objectBuffer, offset: 0, index: 0)
                renderEncoder.setFragmentTexture(texture, index: 0)
                renderEncoder.setFragmentSamplerState(samplerState, index: 0)
                renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: SummerObject.objectVertices * objectMaxDraw)
                renderEncoder.endEncoding()
            }
            commandBuffer.present(view.currentDrawable!)
            commandBuffer.commit()
        }
    }
    
    // Swift will automatically extend array if needed.
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
    
    public func makeColor(red: Float, green: Float, blue: Float, alpha: Float) -> SummerTexture {
        return SummerTexture(self, width: 1, height: 1, data: [red, green, blue, alpha])
    }
    
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
        commandQueue.label = "Main Queue"
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.label = "Basic Pipeline"
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
        
        objectBuffer = device.makeBuffer(length: SummerObject.objectSize * programInfo.maxObjects)
        objectAllocationData = [Bool](repeating: false, count: programInfo.maxObjects)
        if objectBuffer == nil { throw SummerError.cannotCreateObjectBuffer }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: MTLPixelFormat.rgba8Unorm,
            width: programInfo.textureAllocWidth, height: programInfo.textureAllocHeight,
            mipmapped: false)
        
        texture = device.makeTexture(descriptor: textureDescriptor)
        textureAllocationData = [Bool](repeating: false, count: programInfo.textureAllocWidth * programInfo.textureAllocHeight)
        if texture == nil { throw SummerError.cannotCreateTexture }
        
        super.init()
        
        if !view.setEngine(engine: self) { throw SummerError.viewInUse }
        program.setup(engine: self)
        program.message(message: .loop)
    }
}
