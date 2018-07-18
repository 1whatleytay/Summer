//
//  SummerTexture.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-23.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Metal
import AppKit

public class SummerTexture {
    private let parent: SummerEngine
    internal let x, y, width, height: Int
    internal let vertX1, vertX2, vertY1, vertY2: Float
    
    public static func makeNil(_ parent: SummerEngine) -> SummerTexture {
        return SummerTexture(parent, x: 0, y: 0, width: 0, height: 0)
    }
    
    public func getSize() -> (width: Int, height: Int) { return (width: width, height: height) }
    
    public static func getTextureData(fromFile file: String, _ location: SummerFileLocation) ->
        (width: Int, height: Int, data: [Float])? {
            var imageData: [Float]
            var width = 0, height = 0
            
            if let image = location == .inFolder ? NSImage(contentsOfFile: file) : NSImage(named: file) {
                width = Int(image.size.width)
                height = Int(image.size.height)
                
                imageData = [Float](repeating: 0, count: width * height * 4)
                
                guard let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)
                    else { return nil }
                
                for x in 0 ..< width {
                    for y in 0 ..< height {
                        let color = bitmap.colorAt(x: x, y: y)!
                        
                        imageData[(x + y * width) * 4] = Float(color.redComponent)
                        imageData[(x + y * width) * 4 + 1] = Float(color.greenComponent)
                        imageData[(x + y * width) * 4 + 2] = Float(color.blueComponent)
                        imageData[(x + y * width) * 4 + 3] = Float(color.alphaComponent)
                    }
                }
            } else { return nil }
            
            return (width: width, height: height, data: imageData)
    }
    
    internal static func allocate(_ parent: SummerEngine, width: Int, height: Int) -> (x: Int, y: Int) {
        var found = false
        var findX = -1, findY = -1
        
        for scanX in 0 ..< (parent.features.textureAllocWidth - width + 1) {
            for scanY in 0 ..< (parent.features.textureAllocHeight - height + 1) {
                var isFound = false
                for scanPX in 0 ..< width {
                    for scanPY in 0 ..< height {
                        if parent.textureAllocationData[(scanX + scanPX) +
                                (scanY + scanPY) * parent.features.textureAllocWidth] {
                            isFound = true
                            break
                        }
                    }
                    if isFound { break }
                }
                if !isFound {
                    found = true
                    findX = scanX
                    findY = scanY
                    break
                }
            }
            if found { break }
        }
        
        return (x: findX, y: findY)
    }
    
    internal func allocate() {
        if parent.settings.debugPrintAllocationMessages {
            print("Allocated texture: \(x), \(y) -> (\(width), \(height))")
        }
        for x in 0 ..< width {
            for y in 0 ..< height {
                parent.textureAllocationData[
                    (self.x + x) + (self.y + y)
                        * parent.features.textureAllocWidth] = true
            }
        }
    }
    
    public func sample(x: Int, y: Int, width: Int, height: Int) -> SummerTexture? {
        if x + width > self.x + self.width || y + height > self.y + self.height { return nil }
        return SummerTexture(parent,
                             x: self.x + x, y: self.y + y,
                             width: self.width + width, height: self.height + height)
    }
    
    public func delete() {
        for sX in 0 ..< width {
            for sY in 0 ..< height {
                parent.textureAllocationData[x + sX + (y + sY) * parent.features.textureAllocWidth] = true
            }
        }
    }
    
    deinit { if parent.settings.deleteTexturesOnDealloc { delete() } }
    
    private init(_ parent: SummerEngine, x: Int, y: Int, width: Int, height: Int) {
        self.parent = parent
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        
        self.vertX1 = Float(x) / Float(parent.features.textureAllocWidth)
        self.vertX2 = Float(x + width) / Float(parent.features.textureAllocWidth)
        self.vertY1 = Float(y) / Float(parent.features.textureAllocHeight)
        self.vertY2 = Float(y + height) / Float(parent.features.textureAllocHeight)
    }
    
    internal convenience init(_ parent: SummerEngine, width: Int, height: Int, data: [UInt8]) {
        let pos = SummerTexture.allocate(parent, width: width, height: height)
        
        if pos.x == -1 {
            parent.program.message(message: .outOfTextureMemory)
        } else {
            parent.texture.replace(region: MTLRegionMake2D(pos.x, pos.y, width, height), mipmapLevel: 0, withBytes: data, bytesPerRow: width * 4)
        }
        
        self.init(parent, x: pos.x, y: pos.y, width: width, height: height)
        
        allocate()
    }
    
    internal convenience init(_ parent: SummerEngine, width: Int, height: Int, data: [Float]) {
        var subData = [UInt8](repeating: 0, count: data.count)
        for i in 0 ..< data.count {
            subData[i] = UInt8(data[i] * 255)
        }
        
        self.init(parent, width: width, height: height, data: subData)
    }
    
    internal convenience init?(_ parent: SummerEngine, fromFile file: String, _ location: SummerFileLocation = .inFolder) {
        guard let texData = SummerTexture.getTextureData(fromFile: file, location)
            else { return nil }
        
        self.init(parent, width: texData.width, height: texData.height, data: texData.data)
    }
    
    internal convenience init?(_ parent: SummerEngine, fromFile file: String) {
        self.init(parent, fromFile: file, parent.settings.defaultTextureLocation)
    }
}
