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
public class SummerMap: SummerResource {
    internal static let metadataSize = MemoryLayout<UInt32>.size * 10
    
    private let parent: SummerEngine
    
    private let buffer: MTLBuffer!
    public let width, height: Int
    public let unitX, unitY: Float
    public let final : Bool
    
    private var _tileset: SummerTileset
    /// The map tileset.
    public var tileset: SummerTileset {
        get { return _tileset }
        set {
            if !final {
                _tileset = newValue
                
                remakeMetadata()
            }
        }
    }
    
    /// The map transform.
    public var transform: SummerTransform
    
    public var filter: SummerFilter
    
    private func remakeMetadata() {
        if final { return }
        
        let metadata = [
            UInt32(width), UInt32(height),
            UInt32(_tileset.width), UInt32(_tileset.height),
            UInt32(_tileset.tileWidth), UInt32(_tileset.tileHeight),
            UInt32(_tileset.width / _tileset.tileWidth), UInt32(_tileset.height / _tileset.tileHeight),
            unitX.bitPattern, unitY.bitPattern
        ]
        
        buffer.contents().copyMemory(from: metadata, byteCount: 4 * 10)
    }
    
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
    
    public func resourceList() -> SummerResourceList { return SummerResourceList(transforms: [transform]) }
    
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
    public func withTransform(_ transform: SummerTransform) -> SummerMap {
        self.transform = transform
        
        return self
    }
    
    /// Creates a new transform.
    ///
    /// - Returns: Self.
    public func withTransform() -> SummerMap {
        return withTransform(parent.makeTransform())
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
        
        self._tileset = tileset
        self.transform = transform
        
        self.unitX = unitX
        self.unitY = unitY
        
        self.filter = parent.settings.mapFilter
        
        self.final = final
        
        var metadata = [
            UInt32(width), UInt32(height),
            UInt32(tileset.width), UInt32(tileset.height),
            UInt32(tileset.tileWidth), UInt32(tileset.tileHeight),
            UInt32(tileset.width / tileset.tileWidth), UInt32(tileset.height / tileset.tileHeight),
            unitX.bitPattern, unitY.bitPattern
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
}
