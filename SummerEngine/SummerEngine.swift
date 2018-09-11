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
    - Allow for programs to specify features and settings
 
 Cool Features:
    - Single File Tileset Loading (GIF and Tileset Image)
    - Combined Transforms
    - Buttons and Better Events
    - Batch Tileset/Animation loading
    - Animation Improvements (seperate timers...)
    - Give maps depth control (in the back layer)
    - Object states, texture states, transform states...
    - Overlay programs ontop of each other
 
 Just in case I forget:
    - Update SummerDraw's makeObject functions
    - Make SummerObject's x y width and height computed properties (auto-save)
    - SummerView fixes (compact, remove subscriptions, fix mouse issues where it teleports on another window)
    - Bind buffers to metal states
    - Filters per map
    - SummerColor color spaces?
    - SummerTileset/SummerMap duplicate method with alloc.
 
 Fixes:
    - Mouse flipping should not be using Units (exclusively, mostly Amps) and should be applied to x and y
 */

/// Stores instance resources and hosts methods for creating objects.
public class SummerEngine : NSObject, MTKViewDelegate {
    private var program: SummerProgram
    private var layers = [SummerProgram]()
    /// Engine settings, for quickly changing how the engine behaves.
    public var settings: SummerSettings
    /// Engine features, for checking if your application is compatible with this engine instance.
    public let features: SummerFeatures
    private let view: SummerView
    
    internal let device: MTLDevice!
    internal let commandQueue: MTLCommandQueue!
    
    internal let objectBuffer: MTLBuffer!
    internal let transformBuffer: MTLBuffer!
    internal let pivotBuffer: MTLBuffer!
    internal let texture: MTLTexture!
    
    private let pipelineState: MTLRenderPipelineState
    private let nearestSampler, linearSampler: MTLSamplerState
    
    internal var objectAllocationData: [Bool]
    internal var transformAllocationData: [Bool]
    internal var textureAllocationData: [Bool]
    
    private var objectModifyQueue = [SummerObject]()
    private var transformModifyQueue = [SummerTransform]()
    
    internal var disposables = Queue<SummerObject>()
    
    private func getSampler(filter: SummerFilter) -> MTLSamplerState {
        return filter == .linear ? linearSampler : nearestSampler
    }
    
    /// A draw that is used by default if another draw is not specified.
    public private(set) var globalDraw: SummerDraw!
    /// A transform that is used by default if another transform is not specified.
    public private(set) var globalTransform: SummerTransform!
    
    /// If another draw is not specified, objects use this draw.
    public var defaultObjectDraw: SummerDraw {
        get { return settings.autoMakeDrawWithObject ? makeDraw() : globalDraw }
    }
    /// If another transform is not specified, objects use this transform.
    public var defaultObjectTransform: SummerTransform {
        get { return settings.autoMakeTransformWithObject ? makeTransform() : globalTransform }
    }
    /// If another transform is not specified, maps use this transform.
    public var defaultMapTransform: SummerTransform {
        get { return settings.autoMakeTranformWithMap ? makeTransform() : globalTransform }
    }
    
    /// A list of resources that will not be deleted when allocations are freed.
    public var globalResources = SummerResourceList()
    
    private let mapPipelineState: MTLRenderPipelineState
    internal var maps = [SummerMap]()
    internal let draws = LinkedList<SummerDraw>()
    
    /// A list of functions that are executed before the program update function.
    public var beforeUpdateEvents = [() -> Void]()
    /// A list of functions that are executed after the program update function.
    public var afterUpdateEvents = [() -> Void]()
    
    private var isAborting = false
    /// Halts execution of the engine.
    public func abort() {
        settings.messageHandler?(.aborting)
        isAborting = true
    }
    
    internal func addObjectModify(_ object: SummerObject) { objectModifyQueue.append(object) }
    internal func addTransformModify(_ transform: SummerTransform) { transformModifyQueue.append(transform) }
    
    internal func hasMoreObjectSpace() -> Bool {
        if disposables.isEmpty { return false }
        
        disposables.dequeue()?.delete()
        
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
    
    // Updates the view's contents upon receiving a change in layout, resolution, or size.
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    /// Draws the view's contents.
    public func draw(in view: MTKView) { step() }
    
    private func step() {
        if isAborting {
            view.delegate = nil
            return
        }
        for event in beforeUpdateEvents { event() }
        program.update()
        for layer in layers { layer.update() }
        dequeueModifies()
        if let commandBuffer = commandQueue.makeCommandBuffer() {
            let renderPassDescriptor = view.currentRenderPassDescriptor!
            let color = settings.clearColor
            renderPassDescriptor.colorAttachments[0].clearColor
                = color.makeClearColor()
            
            if let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) {
                var cfilter: SummerFilter? = nil
                if maps.count > 0 {
                    renderEncoder.setRenderPipelineState(mapPipelineState)
                    renderEncoder.setVertexBuffer(transformBuffer, offset: 0, index: 2)
                    for map in maps {
                        if cfilter != map.filter {
                            cfilter = map.filter
                            renderEncoder.setFragmentSamplerState(getSampler(filter: cfilter!), index: 0)
                        }
                        print("Rendering map: \(map.width)x\(map.height)")
                        map.setResources(renderEncoder)
                        map.addDraws(renderEncoder)
                    }
                }
                
                renderEncoder.setRenderPipelineState(pipelineState)
                renderEncoder.setVertexBuffer(objectBuffer, offset: 0, index: 0)
                renderEncoder.setVertexBuffer(transformBuffer, offset: 0, index: 1)
                renderEncoder.setVertexBuffer(pivotBuffer, offset: 0, index: 2)
                
                renderEncoder.setFragmentTexture(texture, index: 0)
                for draw in draws {
                    if cfilter != draw.filter {
                        cfilter = draw.filter
                        renderEncoder.setFragmentSamplerState(getSampler(filter: cfilter!), index: 0)
                    }
                    draw.addDraws(encoder: renderEncoder)
                }
                if cfilter != globalDraw.filter {
                    cfilter = globalDraw.filter
                    renderEncoder.setFragmentSamplerState(getSampler(filter: cfilter!), index: 0)
                }
                globalDraw.addDraws(encoder: renderEncoder)
                renderEncoder.endEncoding()
            }
            
            commandBuffer.present(view.currentDrawable!)
            commandBuffer.commit()
        }
        for event in afterUpdateEvents { event() }
    }
    
    /// Detects the display size and changes related settings.
    public func autoDetectDisplaySize() {
        settings.displayWidth = Int(view.drawableSize.width) / 2
        settings.displayHeight = Int(view.drawableSize.height) / 2
        settings.horizontalUnit = 1 / (Float(view.drawableSize.width) / 2)
        settings.verticalUnit = 1 / (Float(view.drawableSize.height) / 2)
    }
    
    /// Removes all disposable objects and transforms.
    public func clearDisposables() {
        for _ in 0 ..< disposables.count { disposables.dequeue()?.delete() }
    }
    
    private func freeAllocations() {
        objectAllocationData = [Bool](repeating: false, count: features.maxObjects)
        transformAllocationData = [Bool](repeating: false, count: features.maxTransforms + 1)
        textureAllocationData = [Bool](repeating: false,
                                       count: features.textureAllocWidth * features.textureAllocHeight)
        
        globalDraw = SummerDraw(self)
        globalTransform = SummerTransform(self)
        draws.removeAll()
        maps.removeAll()
        clearDisposables()
        
        globalResources.allocate(self)
    }
    
    /// Frees all allocations except for certain objects passed in arrays.
    ///
    /// - Parameter keep: The resources that will not be freed.
    public func freeAllocations(keep resources: SummerResourceList = SummerResourceList()) {
        freeAllocations()
        
        resources.allocate(self)
    }
    
    private func swapPrograms(_ newProgram: SummerProgram,
                              overrideSettingsClear: Bool,
                              keepResources: Bool = false) -> SummerProgram {
        let oldProgram = program
        
        if !keepResources { freeAllocations() }
        
        if features.clearSettingsOnProgramSwap && !overrideSettingsClear {
            settings = SummerSettings()
            autoDetectDisplaySize()
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
    ///   - keep: If true, no resources will be deleted.
    /// - Returns: The last program.
    @discardableResult public func swapPrograms(_ newProgram: SummerProgram, keepResources: Bool = false) -> SummerProgram {
        return swapPrograms(newProgram, overrideSettingsClear: false, keepResources: keepResources)
    }
    
    /// Changes the current program.
    ///
    /// - Parameters:
    ///   - newProgram: The new program.
    ///   - keep: If true, no resources will be deleted.
    /// - Returns: The last program.
    @discardableResult public func swapPrograms(_ newProgram: SummerEntry, keepResources: Bool = false) -> SummerProgram {
        settings = newProgram.settings()
        
        return swapPrograms(newProgram, overrideSettingsClear: true, keepResources: keepResources)
    }
    
    /// Changes the current program.
    ///
    /// - Parameters:
    ///   - newProgram: The new program.
    ///   - keep: The resources that will be kept after the swap.
    /// - Returns: The last program.
    @discardableResult public func swapPrograms(_ newProgram: SummerProgram,
                                                keep resources: SummerResourceList) -> SummerProgram {
        freeAllocations(keep: resources)
        
        return swapPrograms(newProgram, keepResources: true)
    }
    
    /// Changes the current program.
    ///
    /// - Parameters:
    ///   - newProgram: The new program.
    ///   - keep: The resources that will be kept after the swap.
    /// - Returns: The last program.
    @discardableResult public func swapPrograms(_ newProgram: SummerEntry,
                                                keep resources: SummerResourceList) -> SummerProgram {
        freeAllocations(keep: resources)
        
        settings = newProgram.settings()
        
        return swapPrograms(newProgram, overrideSettingsClear: true, keepResources: true)
    }
    
    /// Executes another program ontop of the current program.
    ///
    /// - Parameter layer: The program to be layered.
    public func overlayProgram(_ layer: SummerProgram) {
        layers.append(layer)
        layer.setup(engine: self)
    }
    
    /// Removes a program that was layered ontop of the current program.
    ///
    /// - Parameter layer: The program to be removed.
    public func stripProgram(_ layer: SummerProgram) {
        var findLoc = -1
        for i in 0 ..< layers.count {
            if layers[i] === layer {
                findLoc = i
                break
            }
        }
        if findLoc != -1 { layers.remove(at: findLoc) }
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
        let key = SummerKey(rawValue: key) ?? .vkUnknown
        program.key(key: key, characters: characters, state: state)
        for layer in layers { layer.key(key: key, characters: characters, state: state) }
    }
    
    internal func mouseButtonChanged(button: SummerMouseButton,
                                     x: Double, y: Double,
                                     state: SummerInputState) {
        program.mouse(button: button,
                      x: x,
                      y: Double(settings.displayHeight) - y,
                      state: state)
        for layer in layers {
            layer.mouse(button: button,
                        x: x,
                        y: Double(settings.displayHeight) - y,
                        state: state)
        }
    }
    
    internal func mouseMoved(x: Double, y: Double) {
        program.mouse(button: .movement,
                      x: x,
                      y: Double(settings.displayHeight) - y,
                      state: .movement)
        for layer in layers {
            layer.mouse(button: .movement,
                        x: x,
                        y: Double(settings.displayHeight) - y,
                        state: .movement)
        }
    }
    
    /// Constructor.
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
                view: SummerView,
                features: SummerFeatures = SummerFeatures(),
                settings: SummerSettings = SummerSettings()) throws {
        self.program = program
        self.features = features
        self.settings = settings
        self.view = view
        
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
        
        let vertexShader = library.makeFunction(name: "vertexShader")!
        let mapVertexShader = library.makeFunction(name: "mapVertexShader")!
        let textureShader = library.makeFunction(name: "textureShader")!
        
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
        samplerDescriptor.rAddressMode = .clampToEdge
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        nearestSampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        linearSampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        
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
        
        globalDraw = SummerDraw(self, isGlobal: true)
        globalTransform = SummerTransform(self, isGlobal: true)
        
        if !view.setEngine(engine: self) { throw SummerError.viewInUse }
        
        autoDetectDisplaySize()
        
        program.setup(engine: self)
        settings.messageHandler?(.looping)
    }
    
    /// Constructor.
    ///
    /// - Parameters:
    ///   - program: The program to be run.
    ///   - nView: The summer view to be drawn to.
    /// - Throws:
    ///   - .couldNotCreateDevice: If the platform is unable to create a metal context.
    ///   - .couldNotCreateResources: If the platform is unable to create important resources.
    ///   - .noDefaultLibrary: If the engine cannot find a default library.
    ///   - .viewInUse: If the view is already being used by another SummerEngine instance.
    public convenience init(_ program: SummerEntry, view: SummerView) throws {
        try self.init(program, view: view, features: program.features(), settings: program.settings())
    }
}
