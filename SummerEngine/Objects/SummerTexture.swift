//
//  SummerTexture.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-23.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Metal
import AppKit

/// Represents an image that can be shown on screen.
public class SummerTexture {
    private let parent: SummerEngine
    private let sampled: Bool
    internal let x, y, width, height: Int
    internal let vertX1, vertX2, vertY1, vertY2: Float
    
    public static func fill(color: SummerColor, width: Int, height: Int) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: width * height * 4)
        for loc in 0 ..< width * height {
            data[loc] = UInt8(color.red * 255)
            data[loc] = UInt8(color.green * 255)
            data[loc] = UInt8(color.blue * 255)
            data[loc] = UInt8(color.alpha * 255)
        }
        return data
    }
    
    public static func convert(data: [Float]) -> [UInt8] {
        var subdata = [UInt8](repeating: 0, count: data.count)
        for i in 0 ..< data.count {
            subdata[i] = UInt8(data[i] * 255)
        }
        
        return subdata
    }
    
    internal static func makeNil(_ parent: SummerEngine) -> SummerTexture {
        return SummerTexture(parent, x: 0, y: 0, width: 0, height: 0)
    }
    
    /// Gets the size of the image.
    ///
    /// - Returns: A tuple containing the width and height of the image.
    public func getSize() -> (width: Int, height: Int) { return (width: width, height: height) }
    
    /// Gathers information about an image file.
    ///
    /// - Parameters:
    ///   - file: A path to an image file.
    ///   - location: The location of the image file. .inBundle for relative, .inFolder for global.
    /// - Returns: A tuple containing the image size and pixel data.
    public static func getTextureData(fromFile file: String, in location: SummerFileLocation) ->
        (width: Int, height: Int, data: [Float])? {
            var imageData: [Float]
            var width = 0, height = 0
            
            if let image = location == .folder ? NSImage(contentsOfFile: file) : NSImage(named: file) {
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
        for x in 0 ..< width {
            for y in 0 ..< height {
                parent.textureAllocationData[
                    (self.x + x) + (self.y + y)
                        * parent.features.textureAllocWidth] = true
            }
        }
    }
    
    /// Samples an image within this texture.
    /// Do not delete sampled textures as this will also delete the space in the parent texture.
    ///
    /// - Parameters:
    ///   - x: The relative x location in this texture (in pixels).
    ///   - y: The relative y location in this texture (in pixels).
    ///   - width: The width of the sampled texture (in pixels).
    ///   - height: The height of the sampled texture (in pixels).
    /// - Returns: The texture object that was sampled.
    public func sample(x: Int, y: Int, width: Int, height: Int) -> SummerTexture {
        if x + width > self.x + self.width || y + height > self.y + self.height { return parent.makeNilTexture() }
        return SummerTexture(parent,
                             x: self.x + x, y: self.y + y,
                             width: width, height: height,
                             sampled: true)
    }
    
    /// Edits a region of the texture.
    ///
    /// - Parameters:
    ///   - x: The x coordinate of the region in the texture that will be replaced.
    ///   - y: The y coordinate of the region in the texture that will be replaced.
    ///   - replaceWidth: The width of the region.
    ///   - replaceHeight: The height of the region.
    ///   - data: The data to replace the region.
    public func edit(x: Int, y: Int, replaceWidth: Int, replaceHeight: Int, data: [UInt8]) {
        if x < 0 || y < 0 || width < 0 || height < 0 { return }
        if x + width > self.width || y + height > self.height { return }
        
        parent.texture.replace(region: MTLRegionMake2D(self.x + x, self.y + y, width, height),
                               mipmapLevel: 0, withBytes: data, bytesPerRow: width * 4)
    }
    
    /// Edits a region of the texture.
    ///
    /// - Parameters:
    ///   - x: The x coordinate of the region in the texture that will be replaced.
    ///   - y: The y coordinate of the region in the texture that will be replaced.
    ///   - replaceWidth: The width of the region.
    ///   - replaceHeight: The height of the region.
    ///   - data: The data to replace the region.
    public func edit(x: Int, y: Int, replaceWidth: Int, replaceHeight: Int, data: [Float]) {
        edit(x: x, y: y, replaceWidth: replaceWidth, replaceHeight: replaceHeight, data: SummerTexture.convert(data: data))
    }
    
    /// Edits a region of the texture.
    ///
    /// - Parameters:
    ///   - x: The x coordinate of the pixel to be replaced.
    ///   - y: The y coordinate of the pixel to be replaced.
    ///   - color: The new color of the pixel.
    public func edit(x: Int, y: Int, color: SummerColor) {
        edit(x: x, y: y, replaceWidth: 1, replaceHeight: 1, data: color.data)
    }
    
    /// Creates a new texture with the same properties.
    ///
    /// - Returns: A duplicate texture.
    public func duplicate() -> SummerTexture {
        let pos = SummerTexture.allocate(parent, width: width, height: height)
        
        if pos.x == -1 {
            parent.settings.messageHandler?(.outOfTextureMemory)
        } else {
            if let commandBuffer = parent.commandQueue.makeCommandBuffer() {
                if let blit = commandBuffer.makeBlitCommandEncoder() {
                    blit.copy(from: parent.texture,
                              sourceSlice: 0, sourceLevel: 0,
                              sourceOrigin: MTLOriginMake(x, y, 0),
                              sourceSize: MTLSizeMake(width, height, 0),
                              to: parent.texture,
                              destinationSlice: 0, destinationLevel: 0,
                              destinationOrigin: MTLOriginMake(pos.x, pos.y, 0))
                    blit.endEncoding()
                }
                commandBuffer.commit()
                
                let texture = SummerTexture(parent, x: pos.x, y: pos.y, width: width, height: height)
                texture.allocate()
                return texture
            } else { return parent.makeNilTexture() }
        }
        
        return parent.makeNilTexture()
    }
    
    /// Frees all resources used by this texture.
    public func delete() {
        for sX in 0 ..< width {
            for sY in 0 ..< height {
                parent.textureAllocationData[x + sX + (y + sY) * parent.features.textureAllocWidth] = true
            }
        }
        
        if parent.settings.clearDeletedMemory {
            
        }
    }
    
    deinit { if !sampled { delete() } }
    
    private init(_ parent: SummerEngine, x: Int, y: Int, width: Int, height: Int, sampled: Bool = false) {
        self.parent = parent
        
        self.sampled = sampled
        
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
            parent.settings.messageHandler?(.outOfTextureMemory)
        } else {
            parent.texture.replace(region: MTLRegionMake2D(pos.x, pos.y, width, height), mipmapLevel: 0, withBytes: data, bytesPerRow: width * 4)
        }
        
        self.init(parent, x: pos.x, y: pos.y, width: width, height: height)
        
        allocate()
    }
}
