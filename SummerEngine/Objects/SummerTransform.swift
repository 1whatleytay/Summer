//
//  SummerMatrix.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-07.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import Metal
import simd

public class SummerTransform {
    internal static let size = MemoryLayout<simd_float2x2>.size + MemoryLayout<simd_float2>.size * 2
    internal static let pivotSize = MemoryLayout<UInt32>.size
    
    public struct TransformData {
        private let parent: SummerEngine
        
        public var matrix = float2x2(simd_float2(1, 0), simd_float2(0, 1))
        
        public var offset: float2
        public var origin: float2
        
        internal func data() -> [Float] {
            return [
                matrix[0, 0], matrix[0, 1],
                matrix[1, 0], matrix[1, 1],
                offset.x * parent.settings.horizontalUnit * parent.settings.horizontalAmp,
                offset.y * parent.settings.verticalUnit * parent.settings.verticalAmp,
                (origin.x * parent.settings.horizontalUnit * 2 - 1) * parent.settings.horizontalAmp,
                (origin.y * parent.settings.verticalUnit * 2 - 1) * parent.settings.verticalAmp,
            ]
        }
        
        internal init(_ parent: SummerEngine) {
            self.parent = parent
            
            self.offset = float2(0, 0)
            self.origin = float2(Float(parent.settings.displayWidth) / 2,
                                 Float(parent.settings.displayHeight) / 2)
        }
    }
    
    private let parent: SummerEngine
    private let transformId: Int
    internal let isGlobal: Bool
    
    internal var modified = false
    
    public var data: TransformData
    
    public static func allocate(_ parent: SummerEngine) -> Int {
        var indexFind = -1
        for i in 0 ..< parent.transformAllocationData.count {
            if !parent.transformAllocationData[i] {
                indexFind = i
                break
            }
        }
        
        return indexFind
    }
    
    internal func allocate() {
        if parent.settings.debugPrintAllocationMessages {
            print("Allocated transform: \(transformId)")
        }
        parent.transformAllocationData[transformId] = true
    }
    
    public func save() {
        if transformId == -1 { return }
        
        let start = transformId * SummerTransform.size
        let end = start + SummerTransform.size
        
        parent.transformBuffer.contents()
            .advanced(by: start)
            .copyMemory(from: data.data(), byteCount: SummerTransform.size)
        
        parent.transformBuffer.didModifyRange(start..<end)
    }
    
    public func commit() {
        if !modified {
            parent.addTransformModify(self)
            modified = true
        }
    }
    
    internal func pivot(objectId: Int) {
        let start = objectId * SummerTransform.pivotSize
        let end = start + SummerTransform.pivotSize
        
        parent.pivotBuffer.contents()
            .advanced(by: start)
            .copyMemory(from: [transformId], byteCount: SummerTransform.pivotSize)
        
        parent.pivotBuffer.didModifyRange(start..<end)
    }
    
    internal func setMapTransform(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setVertexBuffer(parent.transformBuffer, offset: SummerTransform.size * transformId, index: 2)
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
    }
    
    deinit { if parent.settings.deleteTransformsOnDealloc { delete() } }
    
    private init(_ parent: SummerEngine, transformId: Int, isGlobal: Bool) {
        self.parent = parent
        self.transformId = transformId
        self.isGlobal = isGlobal
        
        self.data = TransformData(parent)
        
        commit()
    }
    
    internal convenience init(_ parent: SummerEngine, isGlobal: Bool = false) {
        let transformId = SummerTransform.allocate(parent)
        if transformId == -1 { parent.program.message(message: .outOfTransformMemory) }
        
        self.init(parent, transformId: transformId, isGlobal: isGlobal)
        
        allocate()
    }
}
