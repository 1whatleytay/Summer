//
//  SummerTileset.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-11.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import Metal

public class SummerTileset {
    private let parent: SummerEngine
    
    internal let texture: MTLTexture!
    internal let tileWidth, tileHeight: Int
    internal let width, height: Int
    
    public static func getTilesetData(fromFiles files: [String], _ location: SummerFileLocation)
        -> (tileWidths: [Int], tileHeights: [Int], data: [[Float]])? {
            if files.count < 1 { return nil }
            
            var data = [[Float]](repeating: [], count: files.count)
            
            var tileWidths = [Int](repeating: -1, count: files.count)
            var tileHeights = [Int](repeating: -1, count: files.count)
            
            for i in 0 ..< files.count {
                guard let imageData = SummerTexture.getTextureData(fromFile: files[i], location)
                    else { return nil }
                
                tileWidths[i] = imageData.width
                tileHeights[i] = imageData.height
                data[i] = imageData.data
            }
            
            return (tileWidths: tileWidths, tileHeights: tileHeights, data: data)
    }
    
    internal init(_ parent: SummerEngine, tileWidth: Int, tileHeight: Int, data: [[UInt8]]) {
        self.parent = parent
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        
        let dimension = Int(ceil(sqrt(Double(data.count))))
        
        width = dimension * tileWidth
        height = dimension * tileHeight
        
        let descriptior =
            MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm,
                                                     width: width, height: height,
                                                     mipmapped: false)
        
        texture = parent.device.makeTexture(descriptor: descriptior)
        
        if texture == nil {
            parent.program.message(message: .couldNotCreateTileset)
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
    
    internal convenience init(_ parent: SummerEngine, tileWidth: Int, tileHeight: Int, data: [[Float]]) {
        var subdata = [[UInt8]](repeating: [UInt8](repeating: 0, count: tileWidth * tileHeight * 4), count: data.count)
        
        for i in 0 ..< data.count {
            for s in 0 ..< data[i].count {
                subdata[i][s] = UInt8(data[i][s] * 255)
            }
        }
        
        self.init(parent, tileWidth: tileWidth, tileHeight: tileHeight, data: subdata)
    }
    
    internal convenience init?(_ parent: SummerEngine, fromFiles files: [String], _ location: SummerFileLocation) {
        guard let tilesetData = SummerTileset.getTilesetData(fromFiles: files, location)
            else {
                parent.program.message(message: .couldNotLoadTileset)
                return nil
        }
        
        self.init(parent,
                  tileWidth: tilesetData.tileWidths[0],
                  tileHeight: tilesetData.tileHeights[0],
                  data: tilesetData.data)
    }
    
    internal convenience init?(_ parent: SummerEngine, fromFiles files: [String]) {
        self.init(parent, fromFiles: files, parent.settings.defaultTextureLocation)
    }
}
