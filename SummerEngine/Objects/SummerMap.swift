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
        for (i, map) in parent.maps.enumerated() {
            if map === self { indexFind = i; break }
        }
        
        return indexFind
    }
    
    public func setActive() {
        let index = getIndexInParent()
        
        if index == -1 { parent.maps.append(self) }
    }
    
    public func setDeactive() {
        let index = getIndexInParent()
        
        if index != -1 { parent.maps.remove(at: index) }
    }
    
    public func makeTransform() -> SummerTransform {
        let newTransform = parent.makeTransform()
        transform = newTransform
        
        return newTransform
    }
    
    public func withTransform(transform newTransform: SummerTransform) -> SummerMap {
        transform = newTransform
        
        return self
    }
    
    public func withTransform() -> SummerMap {
        return withTransform(transform: parent.makeTransform())
    }
    
    internal init(_ parent: SummerEngine,
                  width: Int, height: Int,
                  data: [UInt32],
                  tileset: SummerTileset,
                  transform: SummerTransform,
                  unitX: Float, unitY: Float,
                  mapType: SummerMapType = .staticMap) {
        self.parent = parent
        self.width = width
        self.height = height
        self.tileset = tileset
        self.transform = transform
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
                              transform: SummerTransform,
                              mapType: SummerMapType = .staticMap) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  transform: transform,
                  unitX: 1 / parent.settings.horizontalUnit,
                  unitY: 1 / parent.settings.verticalUnit,
                  mapType: mapType)
    }
    
    internal convenience init(_ parent: SummerEngine,
                              width: Int, height: Int,
                              data: [UInt32],
                              tileset: SummerTileset,
                              unitX: Float, unitY: Float,
                              mapType: SummerMapType = .staticMap) {
        self.init(parent,
                  width: width, height: height,
                  data: data,
                  tileset: tileset,
                  transform: parent.globalTransform,
                  unitX: unitX, unitY: unitY,
                  mapType: mapType)
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
                  transform: parent.globalTransform,
                  unitX: 1 / parent.settings.horizontalUnit,
                  unitY: 1 / parent.settings.verticalUnit,
                  mapType: mapType)
    }
}
