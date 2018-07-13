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
        
        for (i, tex) in data.enumerated() {
            for (s, val) in tex.enumerated() {
                subdata[i][s] = UInt8(val * 255)
            }
        }
        
        self.init(parent, tileWidth: tileWidth, tileHeight: tileHeight, data: subdata)
    }
    
    internal convenience init?(_ parent: SummerEngine, fromFiles files: [String], _ location: SummerFileLocation) {
        var data = [[Float]](repeating: [], count: files.count)
        
        var tileWidth = -1, tileHeight = -1
        
        for (i, file) in files.enumerated() {
            guard let imageData = SummerTexture.getTextureData(fromFile: file, location)
                else {
                    parent.program.message(message: .couldNotFindTexture)
                    return nil
            }
            
            if tileWidth == -1 {
                tileWidth = imageData.width
                tileHeight = imageData.height
            } else if tileWidth != imageData.width || tileHeight != imageData.height {
                parent.program.message(message: .inconsistentTextureSizes)
                return nil
            }
            
            data[i] = imageData.data
        }
        
        if tileWidth == -1 {
            parent.program.message(message: .inconsistentTextureSizes)
            return nil
        }
        
        print("\(tileWidth), \(tileHeight) -> \(data.count)")
        for sub in data {
            print(sub.count)
        }
        
        self.init(parent, tileWidth: tileWidth, tileHeight: tileHeight, data: data)
    }
}
