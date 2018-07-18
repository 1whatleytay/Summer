//
//  SummerMake.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-17.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation

extension SummerEngine {
    public func makeNilTexture() -> SummerTexture { return SummerTexture.makeNil(self) }
    
    public func makeTexture(width: Int, height: Int, data: [UInt8]) -> SummerTexture {
        return SummerTexture(self, width: width, height: height, data: data)
    }
    
    public func makeTexture(width: Int, height: Int, data: [Float]) -> SummerTexture {
        return SummerTexture(self, width: width, height: height, data: data)
    }
    
    public func makeTexture(fromFile file: String,
                            _ location: SummerFileLocation = .inFolder) -> SummerTexture? {
        return SummerTexture(self, fromFile: file, location)
    }
    
    public func makeColor(red: Float, green: Float, blue: Float, alpha: Float) -> SummerTexture {
        return SummerTexture(self, width: 1, height: 1, data: [red, green, blue, alpha])
    }
    
    public func makeDraw() -> SummerDraw { return SummerDraw(self) }
    public func makeTransform() -> SummerTransform { return SummerTransform(self) }
    
    public func makeTileset(tileWidth: Int, tileHeight: Int, data: [[UInt8]]) -> SummerTileset {
        return SummerTileset(self, tileWidth: tileWidth, tileHeight: tileHeight, data: data)
    }
    
    public func makeTileset(tileWidth: Int, tileHeight: Int, data: [[Float]]) -> SummerTileset {
        return SummerTileset(self, tileWidth: tileWidth, tileHeight: tileHeight, data: data)
    }
    
    public func makeTileset(fromFiles files: [String], _ location: SummerFileLocation) -> SummerTileset? {
        return SummerTileset(self, fromFiles: files, location)
    }
    
    public func makeTileset(fromFiles files: [String]) -> SummerTileset? {
        return SummerTileset(self, fromFiles: files)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [UInt32],
                        tileset: SummerTileset,
                        transform: SummerTransform,
                        unitX: Float, unitY: Float,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset, transform: transform,
                         unitX: unitX, unitY: unitY,
                         final: final)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [UInt32],
                        tileset: SummerTileset,
                        transform: SummerTransform,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset, transform: transform,
                         final: final)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [UInt32],
                        tileset: SummerTileset,
                        unitX: Float, unitY: Float,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset,
                         unitX: unitX, unitY: unitY,
                         final: final)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [UInt32],
                        tileset: SummerTileset,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset,
                         final: final)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [Int],
                        tileset: SummerTileset,
                        transform: SummerTransform,
                        unitX: Float, unitY: Float,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset, transform: transform,
                         unitX: unitX, unitY: unitY,
                         final: final)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [Int],
                        tileset: SummerTileset,
                        transform: SummerTransform,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset,
                         transform: transform,
                         final: final)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [Int],
                        tileset: SummerTileset,
                        unitX: Float, unitY: Float,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset,
                         unitX: unitX, unitY: unitY,
                         final: final)
    }
    
    public func makeMap(width: Int, height: Int,
                        data: [Int],
                        tileset: SummerTileset,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset,
                         final: final)
    }
    
    public func makeAnimation(textures: [SummerTexture], animationRate: Double) -> SummerAnimation {
        return SummerAnimation(self, textures: textures, animationRate: animationRate)
    }
    
    public func makeAnimation(widths: [Int], heights: [Int], data: [[UInt8]], animationRate: Double) -> SummerAnimation {
        return SummerAnimation(self, widths: widths, heights: heights, data: data, animationRate: animationRate)
    }
    
    public func makeAnimation(widths: [Int], heights: [Int], data: [[Float]], animationRate: Double) -> SummerAnimation {
        return SummerAnimation(self, widths: widths, heights: heights, data: data, animationRate: animationRate)
    }
    
    public func makeAnimation(fromFiles files: [String], animationRate: Double) -> SummerAnimation? {
        return SummerAnimation(self, fromFiles: files, animationRate: animationRate)
    }
    
    public func makeAnimation(fromFiles files: [String],
                              _ location: SummerFileLocation,
                              animationRate: Double) -> SummerAnimation? {
        return SummerAnimation(self, fromFiles: files, location, animationRate: animationRate)
    }
}
