//
//  SummerObject.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Cocoa

public class SummerObject {
    internal static let vertices = 6
    internal static let size = MemoryLayout<Float>.size * vertices * 4
    
    private let parent: SummerEngine
    private let objectId: Int
    
    internal var modified = false
    
    public var x, y, width, height: Float
    public var texture: SummerTexture
    
    public private(set) var draw: SummerDraw
    public private(set) var transform: SummerTransform
    
    public static func allocate(_ parent: SummerEngine) -> Int {
        var indexFind = -1
        for (index, alloc) in parent.objectAllocationData.enumerated() {
            if !alloc {
                indexFind = index
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
    
    public func save() {
        if objectId == -1 { return }
        
        let start = objectId * SummerObject.size
        let end = start + SummerObject.size
        
        parent.objectBuffer.contents()
            .advanced(by: start)
            .copyMemory(from: objectData(), byteCount: SummerObject.size)
        
        parent.objectBuffer.didModifyRange(start ..< end)
    }
    
    public func commit() {
        if !modified {
            parent.addObjectModify(self)
            modified = true
        }
    }
    
    public func setDraw(to newDraw: SummerDraw) {
        draw.removeIndex(index: objectId)
        
        newDraw.addIndex(index: objectId)
        draw = newDraw
    }
    
    @discardableResult public func makeDraw() -> SummerDraw {
        let newDraw = SummerDraw(parent)
        setDraw(to: newDraw)
        
        return newDraw
    }
    
    public func withDraw() -> SummerObject {
        makeDraw()
        
        return self
    }
    
    public func setTransform(to newTransform: SummerTransform) {
        newTransform.pivot(objectId: objectId)
        
        transform = newTransform
    }
    
    @discardableResult public func makeTransform() -> SummerTransform {
        let newTransform = SummerTransform(parent)
        setTransform(to: newTransform)
        
        return newTransform
    }
    
    public func withTransform(transform newTransform: SummerTransform) -> SummerObject {
        setTransform(to: newTransform)
        
        return self
    }
    
    public func withTransform() -> SummerObject {
        return withTransform(transform: SummerTransform(parent))
    }
    
    public func texture(_ texture: SummerTexture)  {
        self.texture = texture
        commit()
    }
    
    public func size(width: Float, height: Float) {
        self.width = width
        self.height = height
        commit()
    }
    
    public func put(x: Float, y: Float) {
        self.x = x
        self.y = y
        commit()
    }
    
    public func move(x: Float, y: Float) {
        self.x += x
        self.y += y
        commit()
    }
    
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
                 texture: SummerTexture) {
        self.parent = parent
        self.objectId = objectId
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        
        self.texture = texture
        
        self.draw = draw
        draw.addIndex(index: objectId)
        
        self.transform = parent.globalTransform
        transform.pivot(objectId: objectId)
        
        commit()
    }
    
    public convenience init(_ parent: SummerEngine,
                            draw: SummerDraw,
                            transform: SummerTransform,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture) {
        let objectId = SummerObject.allocate(parent)
        
        if objectId == -1 { parent.program.message(message: .outOfObjectMemory) }
        
        self.init(parent, objectId: objectId,
                  draw: draw,
                  transform: transform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture)
        
        allocate()
    }
    
    public convenience init(_ parent: SummerEngine,
                            draw: SummerDraw,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture) {
        self.init(parent,
                  draw: draw,
                  transform: parent.settings.autoMakeTransformWithObject ? parent.makeTransform() : parent.globalTransform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture)
    }
    
    public convenience init(_ parent: SummerEngine,
                            transform: SummerTransform,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture) {
        self.init(parent,
                  draw: parent.settings.autoMakeDrawWithObject ? parent.makeDraw() : parent.globalDraw,
                  transform: transform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture)
    }
    
    public convenience init(_ parent: SummerEngine,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture) {
        self.init(parent,
                  draw: parent.settings.autoMakeDrawWithObject ? parent.makeDraw() : parent.globalDraw,
                  transform: parent.settings.autoMakeTransformWithObject ? parent.makeTransform() : parent.globalTransform,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture)
    }
}
