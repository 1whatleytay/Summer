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

/// An object that contains information on different transformations.
public class SummerTransform {
    internal static let size = 40
    internal static let pivotSize = 4
    
    private let parent: SummerEngine
    private let transformId: Int
    public let isGlobal: Bool
    
    internal var modified = false
    
    /// The transform's matrix. Used for rotations and scaling.
    public var matrix: float2x2
    
    /// The transform's offset. Used for moving around objects.
    public var offset: float2
    /// The matrix's origin. The point that will be used as an origin for scaling, rotations among other things.
    public var origin: float2
    
    /// The transform's opacity. Provides a way to control a group of object's opacity.
    public var opacity: Float = 1
    
    private func data() -> [Float] {
        return [
            matrix[0, 0], matrix[1, 0],
            matrix[0, 1], matrix[1, 1],
            offset.x * parent.settings.horizontalUnit * parent.settings.horizontalAmp,
            offset.y * parent.settings.verticalUnit * parent.settings.verticalAmp,
            (origin.x * parent.settings.horizontalUnit * 2 - 1) * parent.settings.horizontalAmp,
            (origin.y * parent.settings.verticalUnit * 2 - 1) * parent.settings.verticalAmp,
            opacity, 0
        ]
    }
    
    internal static func allocate(_ parent: SummerEngine) -> Int {
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
        if transformId == -1 { return }
        
        parent.transformAllocationData[transformId] = true
    }
    
    /// Saves all changes.
    public func save() {
        if transformId == -1 { return }
        
        let start = transformId * SummerTransform.size
        let end = start + SummerTransform.size
        
        parent.transformBuffer.contents()
            .advanced(by: start)
            .copyMemory(from: data(), byteCount: SummerTransform.size)
        
        parent.transformBuffer.didModifyRange(start..<end)
    }
    
    /// Marks this object as changed. This object will be saved.
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
        renderEncoder.setVertexBytes([UInt32(transformId)], length: 4, index: 3)
    }
    
    /// Multiples a custom matrix to the current matrix.
    ///
    /// - Parameter matrix: The matrix to be multiplied.
    public func multiply(by change: float2x2) {
        matrix = change * matrix
        
        commit()
    }
    
    /// Scales the matrix.
    ///
    /// - Parameters:
    ///   - x: The horizontal scale factor.
    ///   - y: The vertical scale factor.
    public func scale(x: Float, y: Float) {
        matrix = simd_float2x2(simd_float2(x, 0), simd_float2(0, y)) * matrix
        
        commit()
    }
    
    /// Rotates the matrix.
    ///
    /// - Parameter degree: The amount of degrees to be rotated.
    public func rotate(degree: Float) {
        let radians = degree * Float.pi / 180
        
        matrix = simd_float2x2(simd_float2(cos(radians), -sin(radians)),
                                    simd_float2(sin(radians), cos(radians))) * matrix
        
        commit()
    }
    
    /// Resets the matrix.
    public func setIdentity() {
        matrix = simd_float2x2(simd_float2(1, 0), simd_float2(0, 1))
        
        commit()
    }
    
    /// Moves the camera.
    ///
    /// - Parameters:
    ///   - x: The amount of horizontal units to be moved.
    ///   - y: The amount of vertical units to be moved.
    public func moveCamera(x: Float, y: Float) {
        offset.x -= x
        offset.y -= y
        
        commit()
    }
    
    /// Sets the offset to a camera location.
    ///
    /// - Parameters:
    ///   - x: The x coordinate of the camera.
    ///   - y: The y coordinate of the camera.
    public func setCamera(x: Float, y: Float) {
        offset.x = -x
        offset.y = -y
        
        commit()
    }
    
    /// Moves the offset.
    ///
    /// - Parameters:
    ///   - x: The amount of horizontal units to be moved.
    ///   - y: The amount of vertical units to be moved.
    public func moveOffset(x: Float, y: Float) {
        offset.x += x
        offset.y += y
        
        commit()
    }
    
    /// Sets the offset.
    ///
    /// - Parameters:
    ///   - x: The horizontal offset.
    ///   - y: The vertical offset.
    public func setOffset(x: Float, y: Float) {
        offset.x = x
        offset.y = y
        
        commit()
    }
    
    /// Sets the origin of the matrix.
    ///
    /// - Parameters:
    ///   - x: The x coordinate of the origin.
    ///   - y: The y coordinate of the origin.
    public func setOrigin(x: Float, y: Float) {
        origin.x = x
        origin.y = y
        
        commit()
    }
    
    /// Sets the opacity of the transform.
    ///
    /// - Parameter opacity: The opacity, 0 being transparent and 1 being fully opaque.
    public func setOpacity(_ opacity: Float) {
        self.opacity = opacity
        
        commit()
    }
    
    /// Sets the origin of the matrix to the center of an object.
    ///
    /// - Parameter object: The object whose center will be used as an origin.
    public func setOrigin(centerOf object: SummerObject) {
        origin.x = object.x + object.width / 2
        origin.y = object.y + object.height / 2
    }
    
    /// Creates a new transform with the same properties.
    ///
    /// - Returns: A duplicate transform.
    public func duplicate() -> SummerTransform{
        let transform = SummerTransform(parent)
        
        transform.multiply(by: matrix)
        transform.setOffset(x: offset.x, y: offset.y)
        transform.setOrigin(x: origin.x, y: origin.y)
        transform.setOpacity(opacity)
        
        return transform
    }
    
    /// Frees all resources used by this transform.
    public func delete() {
        if transformId == -1 { return }
        
        parent.transformAllocationData[transformId] = false
    }
    
    deinit { delete() }
    
    internal init(_ parent: SummerEngine, isGlobal: Bool = false) {
        let transformId = SummerTransform.allocate(parent)
        if transformId == -1 { parent.settings.messageHandler?(.outOfTransformMemory) }
        
        self.parent = parent
        self.transformId = transformId
        self.isGlobal = isGlobal
        
        self.matrix = float2x2(1)
        
        self.offset = float2(0)
        self.origin = float2(Float(parent.settings.displayWidth) / 2,
                             Float(parent.settings.displayHeight) / 2)
        
        save()
        
        allocate()
    }
}
