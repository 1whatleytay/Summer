//
//  SummerObject.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Cocoa

public class SummerObject {
    internal static let objectVertices = 6
    internal static let objectSize = MemoryLayout<Float>.size * objectVertices * 4
    
    private let parent: SummerEngine
    private var objectId: Int
    
    public var x, y, width, height: Float
    public var texture: SummerTexture
    
    public private(set) var draw: SummerDraw
    
    public static func allocate(_ parent: SummerEngine) -> Int {
        var indexFind = -1
        for (index, alloc) in parent.objectAllocationData.enumerated() {
            if !alloc {
                indexFind = index
                parent.objectAllocationData[index] = true
                break
            }
        }
        
        return indexFind
    }
    
    private func objectData() -> [Float] {
        let vertX1 = (x * parent.programInfo.horizontalUnit * 2 - 1) * parent.programInfo.horizontalAmp
        let vertX2 = ((x + width) * parent.programInfo.horizontalUnit * 2 - 1) * parent.programInfo.horizontalAmp
        let vertY1 = (y * parent.programInfo.verticalUnit * 2 - 1) * parent.programInfo.verticalAmp
        let vertY2 = ((y + height) * parent.programInfo.verticalUnit * 2 - 1) * parent.programInfo.verticalAmp
        
        return [
            vertX1, vertY1, texture.vertX1, texture.vertY1,
            vertX2, vertY1, texture.vertX2, texture.vertY1,
            vertX1, vertY2, texture.vertX1, texture.vertY2,
            vertX2, vertY1, texture.vertX2, texture.vertY1,
            vertX1, vertY2, texture.vertX1, texture.vertY2,
            vertX2, vertY2, texture.vertX2, texture.vertY2,
        ]
    }
    
    internal func save(data: [Float]) {
        if objectId == -1 { return }
        
        parent.objectBuffer.contents()
            .advanced(by: objectId * SummerObject.objectSize)
            .copyMemory(from: data, byteCount: SummerObject.objectSize)
    }
    
    public func swapDraws(draw newDraw: SummerDraw) {
        draw.removeIndex(index: objectId)
        
        newDraw.addIndex(index: objectId)
        draw = newDraw
    }
    
    @discardableResult public func makeDraw() -> SummerDraw {
        let newDraw = SummerDraw(parent)
        swapDraws(draw: newDraw)
        
        return newDraw
    }
    
    public func withDraw(draw newDraw: SummerDraw) -> SummerObject {
        swapDraws(draw: newDraw)
        
        return self
    }
    
    public func withDraw() -> SummerObject {
        makeDraw()
        
        return self
    }
    
    public func save() {
        save(data: objectData())
    }
    
    public func texture(_ texture: SummerTexture)  {
        self.texture = texture
        save()
    }
    
    public func size(width: Float, height: Float) {
        self.width = width
        self.height = height
        save()
    }
    
    public func put(x: Float, y: Float) {
        self.x = x
        self.y = y
        save()
    }
    
    public func move(x: Float, y: Float) {
        self.x += x
        self.y += y
        save()
    }
    
    public func delete() {
        print("Deleting object: \(objectId)")
        if objectId == -1 { return }
        
        //save(data: [Float](repeating: 0, count: SummerObject.objectVertices * 2))
        draw.removeIndex(index: objectId)
        parent.objectAllocationData[objectId] = false
        objectId = -1
    }
    
    deinit { if parent.programInfo.deleteObjectsOnDealloc { delete() } }
    
    internal init(_ parent: SummerEngine, objectId: Int, draw: SummerDraw, x: Float, y: Float, width: Float, height: Float, texture: SummerTexture) {
        self.parent = parent
        self.objectId = objectId
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        
        self.texture = texture
        
        self.draw = draw
        
        draw.addIndex(index: objectId)
        
        save()
    }
    
    public convenience init(_ parent: SummerEngine,
                            draw: SummerDraw,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture) {
        let objectId = SummerObject.allocate(parent)
        
        if objectId == -1 { parent.program.message(message: .outOfObjectMemory) }
        
        self.init(parent, objectId: objectId,
                  draw: draw,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture)
    }
    
    public convenience init(_ parent: SummerEngine,
                            x: Float, y: Float,
                            width: Float, height: Float,
                            texture: SummerTexture) {
        self.init(parent,
                  draw: parent.objectGlobalDraw,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture)
    }
}
