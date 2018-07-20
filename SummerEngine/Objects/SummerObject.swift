//
//  SummerObject.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// Represents a drawable object on screen.
open class SummerObject {
    internal static let vertices = 6
    internal static let size = MemoryLayout<Float>.size * vertices * 4
    
    private let parent: SummerEngine
    private let objectId: Int
    
    internal var modified = false

    /// The x coordinate of the object (in units).
    public var x: Float
    /// The y coordinate of the object (in units).
    public var y: Float
    /// The width of the object (in units).
    public var width: Float
    /// The height of the object (in units).
    public var height: Float
    
    /// The texture for the object.
    public var texture: SummerTexture
    /// The animation that is currently animating this object.
    public internal(set) var animation: SummerAnimation?
    
    /// If true, the object will be drawn to the screen. Use show() and hide() to manipulate this value.
    public private(set) var isVisible: Bool
    /// If true, this object will be deleted when the engine is low on memory.
    public private(set) var isDisposable = false
    
    /// The draw this object belongs to.
    public private(set) var draw: SummerDraw
    /// The transform that contains transformation data for this object.
    public private(set) var transform: SummerTransform
    
    internal static func allocate(_ parent: SummerEngine) -> Int {
        var indexFind = -1
        for i in 0 ..< parent.objectAllocationData.count {
            if !parent.objectAllocationData[i] {
                indexFind = i
                break
            }
        }
        
        return indexFind
    }
    
    internal func allocate() {
        if parent.settings.debugPrintAllocationMessages {
            print("Allocate Object: \(objectId)")
        }
        parent.objectAllocationData[objectId] = true
    }
    
    private func objectData() -> [Float] {
        let vertX1 = (x * parent.settings.horizontalUnit * 2 - 1) * parent.settings.horizontalAmp
        let vertX2 = ((x + width) * parent.settings.horizontalUnit * 2 - 1) * parent.settings.horizontalAmp
        let vertY1 = (y * parent.settings.verticalUnit * 2 - 1) * parent.settings.verticalAmp
        let vertY2 = ((y + height) * parent.settings.verticalUnit * 2 - 1) * parent.settings.verticalAmp
        
        return [
            vertX1, vertY1, texture.vertX1, texture.vertY1,
            vertX2, vertY1, texture.vertX2, texture.vertY1,
            vertX1, vertY2, texture.vertX1, texture.vertY2,
            vertX2, vertY1, texture.vertX2, texture.vertY1,
            vertX1, vertY2, texture.vertX1, texture.vertY2,
            vertX2, vertY2, texture.vertX2, texture.vertY2,
        ]
    }
    
    /// Saves all changes to this object.
    public func save() {
        if objectId == -1 { return }
        
        let start = objectId * SummerObject.size
        let end = start + SummerObject.size
        
        parent.objectBuffer.contents()
            .advanced(by: start)
            .copyMemory(from: objectData(), byteCount: SummerObject.size)
        
        parent.objectBuffer.didModifyRange(start ..< end)
    }
    
    /// Marks this object as changed. This object will be saved.
    public func commit() {
        if !modified {
            parent.addObjectModify(self)
            modified = true
        }
    }
    
    /// Starts animating this object with an animation.
    ///
    /// - Parameter animation: The animaiton to be used.
    public func setAnimation(animation: SummerAnimation) { animation.addObject(self) }
    
    /// Removes any animation this object has been using.
    public func removeAnimation() {  animation?.removeObject(self) }
    
    /// Marks the object as disposable. The object will be deleted when the engine is low on memory.
    public func setDisposable() {
        if !isDisposable {
            isDisposable = true
            parent.disposables.append(self)
        }
    }
    
    /// Marks the object as disposable. The object will be deleted when the engine is low on memory.
    ///
    /// - Returns: Self.
    public func withDisposable() -> SummerObject {
        setDisposable()
        
        return self
    }
    
    /// Sets this object's parent draw.
    ///
    /// - Parameter newDraw: The draw that will be used.
    public func setDraw(to newDraw: SummerDraw) {
        draw.removeIndex(index: objectId)
        
        newDraw.addIndex(index: objectId)
        draw = newDraw
    }
    
    /// Makes a draw. This draw will become this object's parent draw.
    ///
    /// - Returns: A draw object.
    @discardableResult public func makeDraw() -> SummerDraw {
        let newDraw = SummerDraw(parent)
        setDraw(to: newDraw)
        
        return newDraw
    }
    
    /// Makes a new draw. This draw will become this object's parent draw.
    ///
    /// - Returns: Self.
    public func withDraw() -> SummerObject {
        makeDraw()
        
        return self
    }
    
    /// Sets this object's transform.
    ///
    /// - Parameter newTransform: The transform that will be used.
    public func setTransform(to newTransform: SummerTransform) {
        newTransform.pivot(objectId: objectId)
        
        transform = newTransform
    }
    
    /// Makes a transform. This transform will become this object's transform.
    ///
    /// - Returns: A transform object.
    @discardableResult public func makeTransform() -> SummerTransform {
        let newTransform = SummerTransform(parent)
        setTransform(to: newTransform)
        
        return newTransform
    }
    
    /// Sets this object's transform.
    ///
    /// - Parameter newTransform: The transform that will be used.
    /// - Returns: Self.
    public func withTransform(transform newTransform: SummerTransform) -> SummerObject {
        setTransform(to: newTransform)
        
        return self
    }
    
    /// Makes a transform. This transform will become this object's transform.
    ///
    /// - Returns: Self.
    public func withTransform() -> SummerObject {
        return withTransform(transform: parent.makeTransform())
    }
    
    /// Replaces this objects texture with a different texture.
    ///
    /// - Parameter texture: The texture that will replace the current one.
    public func texture(_ texture: SummerTexture)  {
        self.texture = texture
        commit()
    }
    
    /// Resizes the object.
    ///
    /// - Parameters:
    ///   - width: The new width of the object (in units).
    ///   - height: The new height of the object (in units).
    public func size(width: Float, height: Float) {
        self.width = width
        self.height = height
        commit()
    }
    
    /// Puts the object at a specific coordinate.
    ///
    /// - Parameters:
    ///   - x: The new x coordinate of the object (in units).
    ///   - y: The new y coordinate of the object (in units).
    public func put(x: Float, y: Float) {
        self.x = x
        self.y = y
        commit()
    }
    
    /// Moves the object.
    ///
    /// - Parameters:
    ///   - x: The amount of units to be moved horizontally.
    ///   - y: The amount of units to be moved vertically.
    public func move(x: Float, y: Float) {
        self.x += x
        self.y += y
        commit()
    }
    
    /// Hides the object. The object will no longer be visible.
    public func hide() {
        if isVisible {
            draw.removeIndex(index: objectId)
            isVisible = false
        }
    }
    
    /// Shows the object. The object will now be visible.
    public func show() {
        if !isVisible {
            draw.addIndex(index: objectId)
            isVisible = true
        }
    }
    
    /// Sets the objects visibility.
    ///
    /// - Parameter value: If false, the object will be hidden. Otherwise, the object will be visible.
    public func setVisible(value: Bool) {
        if value { show() }
        else { hide() }
    }
    
    /// Toggles object visibility.
    public func toggleVisible() { setVisible(value: !isVisible) }
    
    /// Creates a new identical object.
    ///
    /// - Returns: A duplicate object.
    public func duplicate() -> SummerObject {
        return SummerObject(parent,
                            draw: draw,
                            transform: transform,
                            x: x, y: y,
                            width: width, height: height,
                            texture: texture,
                            isVisible: isVisible)
    }
    
    /// Frees all resources used by this object.
    public func delete() {
        if objectId == -1 { return }
        
        draw.removeIndex(index: objectId)
        parent.objectAllocationData[objectId] = false
    }
    
    deinit { if parent.settings.deleteObjectsOnDealloc { delete() } }
    
    private init(_ parent: SummerEngine, objectId: Int,
                 draw: SummerDraw,
                 transform: SummerTransform,
                 x: Float, y: Float,
                 width: Float, height: Float,
                 texture: SummerTexture,
                 isVisible: Bool = true) {
        self.parent = parent
        self.objectId = objectId
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        
        self.texture = texture
        
        self.draw = draw
        self.isVisible = isVisible
        if isVisible { draw.addIndex(index: objectId) }
        
        self.transform = parent.globalTransform
        transform.pivot(objectId: objectId)
        
        commit()
    }
    
    /// Constructor.
    /// Please use SummerEngine.makeObject() for creating raw objects.
    /// This constructor is for creating subclasses.
    ///
    /// - Parameters:
    ///   - parent: The parent engine.
    ///   - draw: The parent draw.
    ///   - transform: The transform of the object.
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - texture: The texture of the object.
    ///   - isVisible: If false, the object will not be shown by default.
    public convenience init(_ parent: SummerEngine,
                            draw: SummerDraw,
                            transform: SummerTransform,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture,
                            isVisible: Bool = true) {
        var objectId = SummerObject.allocate(parent)
        
        if objectId == -1 {
            let success = parent.clearDisposables()
            
            if success { objectId = SummerObject.allocate(parent) }
            else { parent.program.message(message: .outOfObjectMemory) }
        }
        
        self.init(parent, objectId: objectId,
                  draw: draw,
                  transform: transform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture,
                  isVisible: isVisible)
        
        allocate()
    }
    
    /// Constructor.
    /// Please use SummerEngine.makeObject() for creating raw objects.
    /// This constructor is for creating subclasses.
    ///
    /// - Parameters:
    ///   - parent: The parent engine.
    ///   - draw: The parent draw.
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - texture: The texture of the object.
    ///   - isVisible: If false, the object will not be shown by default.
    public convenience init(_ parent: SummerEngine,
                            draw: SummerDraw,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture,
                            isVisible: Bool = true) {
        self.init(parent,
                  draw: draw,
                  transform: parent.settings.autoMakeTransformWithObject ? parent.makeTransform() : parent.globalTransform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture,
                  isVisible: isVisible)
    }
    
    /// Constructor.
    /// Please use SummerEngine.makeObject() for creating raw objects.
    /// This constructor is for creating subclasses.
    ///
    /// - Parameters:
    ///   - parent: The parent engine.
    ///   - transform: The transform of the object.
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - texture: The texture of the object.
    ///   - isVisible: If false, the object will not be shown by default.
    public convenience init(_ parent: SummerEngine,
                            transform: SummerTransform,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture,
                            isVisible: Bool = true) {
        self.init(parent,
                  draw: parent.settings.autoMakeDrawWithObject ? parent.makeDraw() : parent.globalDraw,
                  transform: transform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture,
                  isVisible: isVisible)
    }
    
    /// Constructor.
    /// Please use SummerEngine.makeObject() for creating raw objects.
    /// This constructor is for creating subclasses.
    ///
    /// - Parameters:
    ///   - parent: The parent engine.
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - texture: The texture of the object.
    ///   - isVisible: If false, the object will not be shown by default.
    public convenience init(_ parent: SummerEngine,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture,
                            isVisible: Bool = true) {
        self.init(parent,
                  draw: parent.settings.autoMakeDrawWithObject ? parent.makeDraw() : parent.globalDraw,
                  transform: parent.settings.autoMakeTransformWithObject ? parent.makeTransform() : parent.globalTransform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture,
                  isVisible: isVisible)
    }
    
    /// Constructor.
    /// Please use SummerEngine.makeObject() for creating raw objects.
    /// This constructor is for creating subclasses.
    ///
    /// - Parameters:
    ///   - parent: The parent engine.
    ///   - draw: The parent draw.
    ///   - transform: The transform of the object.
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - animation: The animation that will be animating this object.
    ///   - isVisible: If false, the object will not be shown by default.
    public convenience init(_ parent: SummerEngine,
                            draw: SummerDraw,
                            transform: SummerTransform,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            animation: SummerAnimation,
                            isVisible: Bool = true) {
        self.init(parent,
                  draw: draw,
                  transform: transform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: parent.makeNilTexture(),
                  isVisible: isVisible)
        
        setAnimation(animation: animation)
    }
    
    /// Constructor.
    /// Please use SummerEngine.makeObject() for creating raw objects.
    /// This constructor is for creating subclasses.
    ///
    /// - Parameters:
    ///   - parent: The parent engine.
    ///   - draw: The parent draw.
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - animation: The animation that will be animating this object.
    ///   - isVisible: If false, the object will not be shown by default.
    public convenience init(_ parent: SummerEngine,
                            draw: SummerDraw,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            animation: SummerAnimation,
                            isVisible: Bool = true) {
        self.init(parent,
                  draw: draw,
                  transform: parent.settings.autoMakeTransformWithObject ? parent.makeTransform() : parent.globalTransform,
                  x: x, y: y,
                  width: width, height: height,
                  animation: animation,
                  isVisible: isVisible)
    }
    
    /// Constructor.
    /// Please use SummerEngine.makeObject() for creating raw objects.
    /// This constructor is for creating subclasses.
    ///
    /// - Parameters:
    ///   - parent: The parent engine.
    ///   - transform: The transform of the object.
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - animation: The animation that will be animating this object.
    ///   - isVisible: If false, the object will not be shown by default.
    public convenience init(_ parent: SummerEngine,
                            transform: SummerTransform,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            animation: SummerAnimation,
                            isVisible: Bool = true) {
        self.init(parent,
                  draw: parent.settings.autoMakeDrawWithObject ? parent.makeDraw() : parent.globalDraw,
                  transform: transform,
                  x: x, y: y,
                  width: width, height: height,
                  animation: animation,
                  isVisible: isVisible)
    }
    
    /// Constructor.
    /// Please use SummerEngine.makeObject() for creating raw objects.
    /// This constructor is for creating subclasses.
    ///
    /// - Parameters:
    ///   - parent: The parent engine.
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - animation: The animation that will be animating this object.
    ///   - isVisible: If false, the object will not be shown by default.
    public convenience init(_ parent: SummerEngine,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            animation: SummerAnimation,
                            isVisible: Bool = true) {
        self.init(parent,
                  draw: parent.settings.autoMakeDrawWithObject ? parent.makeDraw() : parent.globalDraw,
                  transform: parent.settings.autoMakeTransformWithObject ? parent.makeTransform() : parent.globalTransform,
                  x: x, y: y,
                  width: width, height: height,
                  animation: animation,
                  isVisible: isVisible)
    }
}
