//
//  SummerMap.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-12.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import Metal

public class SummerMap {
    internal static let metadataSize = MemoryLayout<UInt32>.size * 10
    
    private let parent: SummerEngine
    
    private let buffer: MTLBuffer!
    private let width, height: Int
    private let mapType: SummerMapType
    
    public private(set) var tileset: SummerTileset
    
    internal func setResources(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(buffer, offset: SummerMap.metadataSize, index: 1)
        renderEncoder.setFragmentTexture(tileset.texture, index: 0)
    }
    
    internal func addDraws(_ renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6 * width * height)
    }
    
    public func setCurrent() { parent.currentMap = self }
    
    internal init(_ parent: SummerEngine,
                  width: Int, height: Int,
                  data: [UInt32],
                  tileset: SummerTileset,
                  unitX: Float, unitY: Float,
                  mapType: SummerMapType = .staticMap) {
        self.parent = parent
        self.width = width
        self.height = height
        self.tileset = tileset
        self.mapType = mapType
        
        var options: MTLResourceOptions
        switch mapType {
        case .readonlyMap:
            options = .storageModePrivate
        case .staticMap:
            options = .storageModeManaged
        case .dynamicMap:
            options = .storageModeShared
        }
        
        var metadata: [UInt32] = [
            UInt32(width), UInt32(height),
            UInt32(tileset.width), UInt32(tileset.height),
            UInt32(tileset.tileWidth), UInt32(tileset.tileHeight),
            UInt32(tileset.width / tileset.tileWidth), UInt32(tileset.height / tileset.tileHeight),
            UInt32(unitX), UInt32(unitY)
        ]
        
        metadata.append(contentsOf: data)
        
        buffer = parent.device.makeBuffer(bytes: metadata,
                                          length: SummerMap.metadataSize + width * height * 4,
                                          options: options)
        
        if buffer == nil {
            parent.program.message(message: .couldNotCreateMap)
            return
        }
    }
    
    internal convenience init(_ parent: SummerEngine,
                  width: Int, height: Int,
                  data: [UInt32],
                  tileset: SummerTileset,
                  mapType: SummerMapType = .staticMap) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  unitX: 1 / parent.settings.horizontalUnit,
                  unitY: 1 / parent.settings.verticalUnit,
                  mapType: mapType)
    }
}
