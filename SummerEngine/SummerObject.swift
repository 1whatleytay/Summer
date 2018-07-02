//
//  SummerObject.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Cocoa

public class SummerObject {
    public static let objectVertices = 6
    public static let objectSize = MemoryLayout<Float>.size * objectVertices * 4
    
    private let parent: SummerEngine
    private var objectId: Int
    
    public var x, y, width, height: Float
    public var texture: SummerTexture
    
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
        
        let texCoordX1 = Float(texture.x) / Float(parent.programInfo.textureAllocWidth)
        let texCoordX2 = Float(texture.x + texture.width) / Float(parent.programInfo.textureAllocWidth)
        let texCoordY1 = Float(texture.y) / Float(parent.programInfo.textureAllocWidth)
        let texCoordY2 = Float(texture.y + texture.height) / Float(parent.programInfo.textureAllocWidth)
        
        return [
            vertX1, vertY1, texCoordX1, texCoordY1,
            vertX2, vertY1, texCoordX2, texCoordY1,
            vertX1, vertY2, texCoordX1, texCoordY2,
            vertX2, vertY1, texCoordX2, texCoordY1,
            vertX1, vertY2, texCoordX1, texCoordY2,
            vertX2, vertY2, texCoordX2, texCoordY2,
        ]
    }
    
    private func save(data: [Float]) {
        if objectId == -1 { return }
        
        parent.objectBuffer.contents()
            .advanced(by: objectId * SummerObject.objectSize)
            .copyMemory(from: data, byteCount: SummerObject.objectSize)
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
        
        save(data: [Float](repeating: 0, count: SummerObject.objectVertices * 2))
        parent.objectAllocationData[objectId] = false
        objectId = -1
        parent.calculateMaxRenderDraw()
    }
    
    deinit { if parent.programInfo.deleteObjectsOnDealloc { delete() } }
    
    internal init(_ parent: SummerEngine, objectId: Int, x: Float, y: Float, width: Float, height: Float, texture: SummerTexture) {
        self.parent = parent
        self.objectId = objectId
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        
        self.texture = texture
        
        save()
    }
    
    public convenience init(_ parent: SummerEngine, x: Float, y: Float, width: Float, height: Float, texture: SummerTexture) {
        let objectId = SummerObject.allocate(parent)
        if objectId == -1 { parent.program.message(message: .outOfObjectMemory) }
        parent.calculateMaxRenderDraw()
        self.init(parent, objectId: objectId,
                  x: x, y: y,
                  width: width, height: height,
                  texture: texture)
    }
    
    public convenience init(x: Float, y: Float, width: Float, height: Float, texture: SummerTexture) {
        self.init(SummerEngine.currentEngine!, x: x, y: y, width: width, height: height, texture: texture)
    }
}
