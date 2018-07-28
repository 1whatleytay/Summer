//
//  SummerMap.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-12.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import Metal

/// Allows for drawing repitive patterns with much less memory.
public class SummerMap {
    internal static let metadataSize = MemoryLayout<UInt32>.size * 10
    
    private let parent: SummerEngine
    
    private let buffer: MTLBuffer!
    private let width, height: Int
    private let final : Bool
    
    /// The used tileset.
    public private(set) var tileset: SummerTileset
    /// The used transform.
    public var transform: SummerTransform
    
    internal func setResources(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(buffer, offset: SummerMap.metadataSize, index: 1)
        renderEncoder.setFragmentTexture(tileset.texture, index: 0)
        transform.setMapTransform(renderEncoder)
    }
    
    internal func addDraws(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6 * width * height)
    }
    
    private func getIndexInParent() -> Int {
        var indexFind = -1
        for i in 0 ..< parent.maps.count {
            if parent.maps[i] === self { indexFind = i; break }
        }
        
        return indexFind
    }
    
    /// Activates the map. The map will now be drawn.
    public func setActive() {
        let index = getIndexInParent()
        
        if index == -1 { parent.maps.append(self) }
    }
    
    /// Deactivates the map. The map will no longer be drawn.
    public func setDeactive() {
        let index = getIndexInParent()
        
        if index != -1 { parent.maps.remove(at: index) }
    }
    
    /// Creates a new transform.
    ///
    /// - Returns: The transform that was created.
    public func makeTransform() -> SummerTransform {
        let newTransform = parent.makeTransform()
        transform = newTransform
        
        return newTransform
    }
    
    /// Sets the current transform.
    ///
    /// - Parameter newTransform: The new transform to be set.
    /// - Returns: Self.
    public func withTransform(transform newTransform: SummerTransform) -> SummerMap {
        transform = newTransform
        
        return self
    }
    
    /// Creates a new transform.
    ///
    /// - Returns: Self.
    public func withTransform() -> SummerMap {
        return withTransform(transform: parent.makeTransform())
    }
    
    /// Changes a tile in the map.
    ///
    /// - Parameters:
    ///   - x: The x location of the tile.
    ///   - y: The y location of the tile.
    ///   - value: An index to replace the tile.
    public func editTile(x: Int, y: Int, value: UInt32) {
        if !final {
            if x >= 0 && y >= 0 && x < width && y < height {
                buffer.contents()
                    .advanced(by: SummerMap.metadataSize + (x + y * width) * MemoryLayout<UInt32>.size)
                    .copyMemory(from: [value], byteCount: MemoryLayout<UInt32>.size)
            }
        }
    }
    
    /// Changes a tile in the map.
    ///
    /// - Parameters:
    ///   - x: The x location of the tile.
    ///   - y: The y location of the tile.
    ///   - value: An index to replace the tile.
    public func editTile(x: Int, y: Int, value: Int) { editTile(x: x, y: y, value: UInt32(value)) }
    
    internal init(_ parent: SummerEngine,
                  width: Int, height: Int,
                  data: [UInt32],
                  tileset: SummerTileset,
                  transform: SummerTransform,
                  unitX: Float, unitY: Float,
                  final: Bool = false) {
        self.parent = parent
        self.width = width
        self.height = height
        self.tileset = tileset
        self.transform = transform
        self.final = final
        
        var metadata: [UInt32] = [
            UInt32(width), UInt32(height),
            UInt32(tileset.width), UInt32(tileset.height),
            UInt32(tileset.tileWidth), UInt32(tileset.tileHeight),
            UInt32(tileset.width / tileset.tileWidth), UInt32(tileset.height / tileset.tileHeight),
            UInt32(unitX), UInt32(unitY)
        ]
        
        metadata.append(contentsOf: data)
        
        let bufferSize = SummerMap.metadataSize + width * height * 4
        let tempBuffer = parent.device.makeBuffer(bytes: metadata,
                                                  length: bufferSize,
                                                  options: final ? .storageModeShared : .storageModeManaged)!
        
        if final {
            buffer = parent.device.makeBuffer(length: bufferSize, options: .storageModePrivate)
            if let commandBuffer = parent.commandQueue.makeCommandBuffer() {
                if let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
                    blitEncoder.copy(from: tempBuffer, sourceOffset: 0, to: buffer, destinationOffset: 0, size: bufferSize)
                    blitEncoder.endEncoding()
                }
                commandBuffer.commit()
            }
        } else {
            buffer = tempBuffer
        }
        
        if buffer == nil {
            parent.settings.messageHandler?(.couldNotCreateMap)
            return
        }
        
        setActive()
    }
    
    internal convenience init(_ parent: SummerEngine,
                              width: Int, height: Int,
                              data: [UInt32],
                              tileset: SummerTileset,
                              transform: SummerTransform,
                              final: Bool = false) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  transform: transform,
                  unitX: 1 / parent.settings.horizontalUnit,
                  unitY: 1 / parent.settings.verticalUnit,
                  final: final)
    }
    
    internal convenience init(_ parent: SummerEngine,
                              width: Int, height: Int,
                              data: [UInt32],
                              tileset: SummerTileset,
                              unitX: Float, unitY: Float,
                              final: Bool = false) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  transform: parent.globalTransform,
                  unitX: unitX, unitY: unitY,
                  final: final)
    }
    
    internal convenience init(_ parent: SummerEngine,
                              width: Int, height: Int,
                              data: [UInt32],
                              tileset: SummerTileset,
                              final: Bool = false) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  transform: parent.globalTransform,
                  unitX: 1 / parent.settings.horizontalUnit,
                  unitY: 1 / parent.settings.verticalUnit,
                  final: final)
    }
    
    internal convenience init(_ parent: SummerEngine,
                  width: Int, height: Int,
                  data: [Int],
                  tileset: SummerTileset,
                  transform: SummerTransform,
                  unitX: Float, unitY: Float,
                  final: Bool = false) {
        var subdata = [UInt32](repeating: 0, count: data.count)
        
        for i in 0 ..< data.count { subdata[i] = UInt32(data[i]) }
        
        self.init(parent,
                  width: width, height: height,
                  data: subdata,
                  tileset: tileset,
                  transform: transform,
                  unitX: unitX, unitY: unitY,
                  final: final)
    }
    
    internal convenience init(_ parent: SummerEngine,
                              width: Int, height: Int,
                              data: [Int],
                              tileset: SummerTileset,
                              transform: SummerTransform,
                              final: Bool = false) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  transform: transform,
                  unitX: 1 / parent.settings.horizontalUnit,
                  unitY: 1 / parent.settings.verticalUnit,
                  final: final)
    }
    
    internal convenience init(_ parent: SummerEngine,
                              width: Int, height: Int,
                              data: [Int],
                              tileset: SummerTileset,
                              unitX: Float, unitY: Float,
                              final: Bool = false) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  transform: parent.globalTransform,
                  unitX: unitX, unitY: unitY,
                  final: final)
    }
    
    internal convenience init(_ parent: SummerEngine,
                              width: Int, height: Int,
                              data: [Int],
                              tileset: SummerTileset,
                              final: Bool = false) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  transform: parent.globalTransform,
                  unitX: 1 / parent.settings.horizontalUnit,
                  unitY: 1 / parent.settings.verticalUnit,
                  final: final)
    }
}
