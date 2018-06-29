//
//  SummerTexture.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-23.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Metal

public class SummerTexture {
    private let parent: SummerEngine
    internal let x, y, width, height: Int
    
    public func getSize() -> [Int] { return [width, height] }
    
    internal static func allocate(_ parent: SummerEngine, width: Int, height: Int, x findX: inout Int, y findY: inout Int) {
        var found = false
        findX = -1
        findY = -1
        
        for scanX in 0 ..< (parent.programInfo.textureAllocWidth - width + 1) {
            for scanY in 0 ..< (parent.programInfo.textureAllocHeight - height + 1) {
                var isFound = false
                for scanPX in 0 ..< width {
                    for scanPY in 0 ..< height {
                        if parent.textureAllocationData[(scanX + scanPX) + (scanY + scanPY) * parent.programInfo.textureAllocWidth] {
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
        
        for x in 0..<width {
            for y in 0..<height {
                parent.textureAllocationData[
                    (findX + x) + (findY + y)
                        * parent.programInfo.textureAllocWidth] = true
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
                parent.textureAllocationData[x + sX + (y + sY) * parent.programInfo.textureAllocWidth] = true
            }
        }
    }
    
    deinit { if parent.programInfo.deleteTexturesOnDealloc { delete() } }
    
    internal init(_ parent: SummerEngine, x: Int, y: Int, width: Int, height: Int) {
        self.parent = parent
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public convenience init(_ parent: SummerEngine, width: Int, height: Int, data: [UInt8]) {
        var findX = 0, findY = 0
        SummerTexture.allocate(parent, width: width, height: height, x: &findX, y: &findY)
        
        if findX == -1 {
            parent.program.message(message: .outOfTextureMemory)
        } else {
            parent.texture.replace(region: MTLRegionMake2D(findX, findY, width, height), mipmapLevel: 0, withBytes: data, bytesPerRow: width * 4)
        }
        
        self.init(parent, x: findX, y: findY, width: width, height: height)
    }
    
    public convenience init(_ parent: SummerEngine, width: Int, height: Int, data: [Float]) {
        var subData = [UInt8](repeating: 0, count: data.count)
        for (index, element) in data.enumerated() {
            subData[index] = UInt8(element * 255)
        }
        
        self.init(parent, width: width, height: height, data: subData)
    }
    
    public convenience init(width: Int, height: Int, data: [UInt8]) {
        self.init(SummerEngine.currentEngine!, width: width, height: height, data: data)
    }
    
    public convenience init(width: Int, height: Int, data: [Float]) {
        self.init(SummerEngine.currentEngine!, width: width, height: height, data: data)
    }
}
