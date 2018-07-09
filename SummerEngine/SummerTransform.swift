//
//  SummerMatrix.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-07.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import simd

public class SummerTransform {
    internal static let size = MemoryLayout<TransformData>.size
    internal static let pivotSize = MemoryLayout<UInt32>.size
    
    public struct TransformData {
        public var matrix = simd_float2x2(simd_float2(1, 0), simd_float2(0, 1))
        
        public var offset = simd_float2(0, 0)
        public var origin = simd_float2(0, 0)
        
        internal func data() -> [Float] {
            return [
                matrix[0, 0], matrix[0, 1],
                matrix[1, 0], matrix[1, 1],
                offset.x, offset.y,
                origin.x, origin.y
            ]
        }
    }
    
    private let parent: SummerEngine
    private var transformId: Int
    
    internal var modified = false
    
    public var data = TransformData()
    
    public static func allocate(_ parent: SummerEngine) -> Int {
        var indexFind = -1
        for (index, alloc) in parent.transformAllocationData.enumerated() {
            if !alloc {
                indexFind = index
                parent.transformAllocationData[index] = true
                break
            }
        }
        
        return indexFind
    }
    
    public func save() {
        if transformId == -1 { return }
        
        parent.transformBuffer.contents()
            .advanced(by: transformId * SummerTransform.size)
            .copyMemory(from: data.data(), byteCount: SummerTransform.size)
    }
    
    public func commit() {
        if !modified {
            parent.addTransformModify(self)
            modified = true
        }
    }
    
    public func pivot(objectId: Int) {
        parent.pivotBuffer.contents()
            .advanced(by: objectId * SummerTransform.pivotSize)
            .copyMemory(from: [transformId], byteCount: SummerTransform.pivotSize)
    }
    
    public func change(matrix: simd_float2x2) {
        data.matrix = matrix * data.matrix
        
        commit()
    }
    
    public func scale(x: Float, y: Float) {
        data.matrix = simd_float2x2(simd_float2(x, 0), simd_float2(0, y)) * data.matrix
        
        commit()
    }
    
    public func rotate(degree: Float) {
        let radians = degree * Float.pi / 180
        
        data.matrix = simd_float2x2(simd_float2(cos(radians), -sin(radians)),
                                         simd_float2(sin(radians), cos(radians))) * data.matrix
        
        commit()
    }
    
    public func setIdentity() {
        data.matrix = simd_float2x2(simd_float2(1, 0), simd_float2(0, 1))
        
        commit()
    }
    
    public func moveCamera(x: Float, y: Float) {
        data.offset.x -= x
        data.offset.y -= y
        
        commit()
    }
    
    public func setCamera(x: Float, y: Float) {
        data.offset.x = -x
        data.offset.y = -y
        
        commit()
    }
    
    public func moveOffset(x: Float, y: Float) {
        data.offset.x += x
        data.offset.y += y
        
        commit()
    }
    
    public func setOffset(x: Float, y: Float) {
        data.offset.x = x
        data.offset.y = y
        
        commit()
    }
    
    public func setOrigin(x: Float, y: Float) {
        data.origin.x = x
        data.origin.y = y
        
        commit()
    }
    
    public func delete() {
        if transformId == -1 { return }
        
        parent.transformAllocationData[transformId] = false
        transformId = -1
    }
    
    private init(_ parent: SummerEngine, transformId: Int) {
        self.parent = parent
        self.transformId = transformId
        
        commit()
    }
    
    internal convenience init(_ parent: SummerEngine) {
        let transformId = SummerTransform.allocate(parent)
        if transformId == -1 { parent.program.message(message: .outOfTransformMemory) }
        
        self.init(parent, transformId: transformId)
    }
}
