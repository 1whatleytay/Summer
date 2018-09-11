//
//  SummerTileset.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-11.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import Metal

/// Keeps track of multiple tiles to be used in a map.
public class SummerTileset {
    private let parent: SummerEngine
    
    internal let texture: MTLTexture!
    internal let width, height: Int
    internal let tilesX, tilesY: Int
    
    /// The width of a tile in the tileset.
    public let tileWidth: Int
    /// The height of a tile in the tileset.
    public let tileHeight: Int
    
    /// The capacity in tiles of the tileset.
    public let capacity: Int
    
    /// Gathers information about multiple image files.
    ///
    /// - Parameters:
    ///   - files: An array of paths to image files.
    ///   - location: The location of the image files.
    /// - Returns: A tuple containing information of each file as an array.
    public static func getTilesetData(fromFiles files: [String], in location: SummerFileLocation)
        -> (tileWidths: [Int], tileHeights: [Int], data: [[Float]])? {
            if files.count < 1 { return nil }
            
            var data = [[Float]](repeating: [], count: files.count)
            
            var tileWidths = [Int](repeating: -1, count: files.count)
            var tileHeights = [Int](repeating: -1, count: files.count)
            
            for i in 0 ..< files.count {
                guard let imageData = SummerTexture.getTextureData(fromFile: files[i], in: location)
                    else { return nil }
                
                tileWidths[i] = imageData.width
                tileHeights[i] = imageData.height
                data[i] = imageData.data
            }
            
            return (tileWidths: tileWidths, tileHeights: tileHeights, data: data)
    }
    
    public static func convert(data: [[Float]]) -> [[UInt8]] {
        var subdata = [[UInt8]](repeating: [UInt8](), count: data.count)
        
        for i in 0 ..< data.count {
            subdata[i] = SummerTexture.convert(data: data[i])
        }
        
        return subdata
    }
    
    /// Edits a region of a tile.
    ///
    /// - Parameters:
    ///   - tileIndex: The index of the tile.
    ///   - x: The x coordinate of the region in the tile to be replaced.
    ///   - y: The y coordinate of the region in the tile to be replaced.
    ///   - replaceWidth: The width of the region.
    ///   - replaceHeight: The height of the region.
    ///   - data: The data to replace the region.
    public func editTile(tileIndex: Int, x: Int, y: Int, replaceWidth: Int, replaceHeight: Int, data: [UInt8]) {
        if tileIndex < 0 || x < 0 || y < 0 || replaceWidth < 0 || replaceHeight < 0 { return }
        if tileIndex >= capacity || x + replaceWidth > tileWidth || y + replaceHeight > tileHeight { return }
        
        let tileX = tileIndex % tilesX
        let tileY = tileIndex % tilesY
        
        texture.replace(region: MTLRegionMake2D(tileX + x, tileY + y, replaceWidth, replaceHeight), mipmapLevel: 0, withBytes: data, bytesPerRow: replaceWidth * 4)
    }
    
    /// Edits a region of a tile.
    ///
    /// - Parameters:
    ///   - tileIndex: The index of the tile.
    ///   - x: The x coordinate of the region in the tile to be replaced.
    ///   - y: The y coordinate of the region in the tile to be replaced.
    ///   - replaceWidth: The width of the region.
    ///   - replaceHeight: The height of the region.
    ///   - data: The data to replace the region.
    public func editTile(tileIndex: Int, x: Int, y: Int, replaceWidth: Int, replaceHeight: Int, data: [Float]) {
        editTile(tileIndex: tileIndex,
                 x: x, y: y,
                 replaceWidth: replaceWidth, replaceHeight: replaceHeight,
                 data: SummerTexture.convert(data: data))
    }
    
    
    /// Replaces an entire tile.
    ///
    /// - Parameters:
    ///   - tileIndex: The index of the tile.
    ///   - data: The data to replace the tile.
    public func setTile(tileIndex: Int, data: [UInt8]) {
        if tileIndex >= capacity { return }
        
        let tileX = tileIndex % tilesX
        let tileY = tileIndex % tilesY
        
        texture.replace(region: MTLRegionMake2D(tileX, tileY, tileWidth, tileHeight),
                        mipmapLevel: 0, withBytes: data, bytesPerRow: tileWidth * 4)
    }
    
    /// Replaces an entire tile.
    ///
    /// - Parameters:
    ///   - tileIndex: The index of the tile.
    ///   - data: The data to replace the tile.
    public func setTile(tileIndex: Int, data: [Float]) {
        setTile(tileIndex: tileIndex, data: SummerTexture.convert(data: data))
    }
    
    internal init(_ parent: SummerEngine, tileWidth: Int, tileHeight: Int, data: [[UInt8]], alloc: Int = 0) {
        self.parent = parent
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        
        let dimension = Int(ceil(sqrt(Double(data.count + alloc))))
        
        width = dimension * tileWidth
        height = dimension * tileHeight
        
        self.capacity = dimension * dimension
        self.tilesX = dimension
        self.tilesY = dimension
        
        let descriptior =
            MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                     width: width, height: height,
                                                     mipmapped: false)
        
        texture = parent.device.makeTexture(descriptor: descriptior)
        
        if texture == nil {
            parent.settings.messageHandler?(.couldNotCreateTileset)
            return
        }
        
        var doneWriting = false
        
        for y in 0 ..< dimension {
            for x in 0 ..< dimension {
                if x + y * dimension >= data.count {
                    doneWriting = true
                    break
                }
                texture.replace(region: MTLRegionMake2D(x * tileWidth, y * tileHeight, tileWidth, tileHeight),
                                mipmapLevel: 0, withBytes: data[x + y * dimension], bytesPerRow: tileWidth * 4)
            }
            if doneWriting { break }
        }
    }
}
