//
//  SummerMake.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-17.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

extension SummerEngine {
    /// Makes an object.
    ///
    /// - Parameters:
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - texture: The texture of the object.
    ///   - isVisible: If false, the object will not be shown by default.
    /// - Returns: A summer object.
    public func makeObject(
        x: Float, y: Float,
        width: Float, height: Float,
        texture: SummerTexture,
        isVisible: Bool = true) -> SummerObject {
        return SummerObject(self,
                            x: x, y: y,
                            width: width, height: height,
                            texture: texture,
                            isVisible: isVisible)
    }
    
    /// Makes an object.
    ///
    /// - Parameters:
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - texture: The texture of the object.
    ///   - isVisible: If false, the object will not be shown by default.
    /// - Returns: A summer object.
    public func makeObject(
        x: Float, y: Float,
        width: Float, height: Float,
        animation: SummerAnimation,
        isVisible: Bool = true) -> SummerObject {
        return SummerObject(self,
                            x: x, y: y,
                            width: width, height: height,
                            animation: animation,
                            isVisible: isVisible)
    }
    
    /// Makes an empty texture.
    ///
    /// - Returns: A texture object.
    public func makeNilTexture() -> SummerTexture { return SummerTexture.makeNil(self) }
    
    /// Makes a texture out of provided bytes.
    ///
    /// - Parameters:
    ///   - width: The width of the texture.
    ///   - height: The height of the texture.
    ///   - data: An array containing the bytes that will be loaded into the texture.
    /// - Returns: A texture object.
    public func makeTexture(width: Int, height: Int, data: [UInt8]) -> SummerTexture {
        return SummerTexture(self, width: width, height: height, data: data)
    }
    
    /// Makes a texture out of provided components.
    ///
    /// - Parameters:
    ///   - width: The width of the texture.
    ///   - height: The height of the texture.
    ///   - data: An array containing the RGBA components of each pixel.
    /// - Returns: A texture object.
    public func makeTexture(width: Int, height: Int, data: [Float]) -> SummerTexture {
        return SummerTexture(self, width: width, height: height, data: data)
    }
    
    /// Makes a texture from an image file.
    ///
    /// - Parameters:
    ///   - file: The path to the file containing the image data.
    ///   - location: An optional parameter to determine if the path is relative (.inBundle) or global (.inFolder).
    /// - Returns: A texture object.
    public func makeTexture(fromFile file: String,
                            _ location: SummerFileLocation = .inFolder) -> SummerTexture? {
        return SummerTexture(self, fromFile: file, location)
    }
    
    /// Makes a texture from an image file.
    ///
    /// - Parameters:
    ///   - file: The path to the file containing the image data.=
    /// - Returns: A texture object.
    public func makeTexture(fromFile file: String) -> SummerTexture? {
        return SummerTexture(self, fromFile: file)
    }
    
    /// Makes a texture that represents a certain color.
    ///
    /// - Parameters:
    ///   - red: The red component of the color.
    ///   - green: The green component of the color.
    ///   - blue: The blue component of the color.
    ///   - alpha: The alpha component of the color.
    /// - Returns: A texture object.
    public func makeColor(red: Float, green: Float, blue: Float, alpha: Float) -> SummerTexture {
        return SummerTexture(self, width: 1, height: 1, data: [red, green, blue, alpha])
    }
    
    /// Makes a draw.
    ///
    /// - Returns: A draw object.
    public func makeDraw() -> SummerDraw { return SummerDraw(self) }
    
    /// Makes a transform.
    ///
    /// - Returns: A transform object.
    public func makeTransform() -> SummerTransform { return SummerTransform(self) }
    
    /// Makes a tileset out of given bytes.
    ///
    /// - Parameters:
    ///   - tileWidth: The width of each tile.
    ///   - tileHeight: The height of each tile.
    ///   - data: A 2D array containing the bytes for each tile.
    /// - Returns: A tileset object.
    public func makeTileset(tileWidth: Int, tileHeight: Int, data: [[UInt8]]) -> SummerTileset {
        return SummerTileset(self, tileWidth: tileWidth, tileHeight: tileHeight, data: data)
    }
    
    /// Makes a tileset out of the given components.
    ///
    /// - Parameters:
    ///   - tileWidth: The width of each tile.
    ///   - tileHeight: The height of each tile.
    ///   - data: A 2D array containing the RGBA components of each tile.
    /// - Returns: A tileset object.
    public func makeTileset(tileWidth: Int, tileHeight: Int, data: [[Float]]) -> SummerTileset {
        return SummerTileset(self, tileWidth: tileWidth, tileHeight: tileHeight, data: data)
    }
    
    /// Makes a tileset out the given files.
    ///
    /// - Parameters:
    ///   - files: An array of file paths to files containing image data.
    ///   - location: An optional parameter to determine if the path is relative (.inBundle) or global (.inFolder).
    /// - Returns: A tileset object.
    public func makeTileset(fromFiles files: [String], _ location: SummerFileLocation) -> SummerTileset? {
        return SummerTileset(self, fromFiles: files, location)
    }
    
    /// Makes a tileset out of the given files.
    ///
    /// - Parameter files: An array of file paths to files containing image data.
    /// - Returns: A tileset object.
    public func makeTileset(fromFiles files: [String]) -> SummerTileset? {
        return SummerTileset(self, fromFiles: files)
    }
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - transform: A transform for moving the map.
    ///   - unitX: A number representing how many tiles can fit on the screen horizontally.
    ///   - unitY: A number representing how many tiles can fit on the screen vertically.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
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
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - transform: A transform for moving the map.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
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
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - unitX: A number representing how many tiles can fit on the screen horizontally.
    ///   - unitY: A number representing how many tiles can fit on the screen vertically.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
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
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
    public func makeMap(width: Int, height: Int,
                        data: [UInt32],
                        tileset: SummerTileset,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset,
                         final: final)
    }
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - transform: A transform for moving the map.
    ///   - unitX: A number representing how many tiles can fit on the screen horizontally.
    ///   - unitY: A number representing how many tiles can fit on the screen vertically.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
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
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - transform: A transform for moving the map.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
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
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - unitX: A number representing how many tiles can fit on the screen horizontally.
    ///   - unitY: A number representing how many tiles can fit on the screen vertically.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
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
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
    public func makeMap(width: Int, height: Int,
                        data: [Int],
                        tileset: SummerTileset,
                        final: Bool = false) -> SummerMap {
        return SummerMap(self,
                         width: width, height: height, data: data,
                         tileset: tileset,
                         final: final)
    }
    
    /// Makes an animation.
    ///
    /// - Parameters:
    ///   - textures: An array of textures (in order) to be animated.
    ///   - animationRate: The amount of time in seconds for each animation frame to be shown.
    /// - Returns: An animation object.
    public func makeAnimation(textures: [SummerTexture], animationRate: Double) -> SummerAnimation {
        return SummerAnimation(self, textures: textures, animationRate: animationRate)
    }
    
    /// Makes an animation out of provided bytes.
    ///
    /// - Parameters:
    ///   - widths: An array containing the widths of each texture.
    ///   - heights: An array containing the heights of each texture.
    ///   - data: A 2D array containing the bytes for each file.
    ///   - animationRate: The amount of time in seconds for each animation frame to be shown.
    /// - Returns: An animation object.
    public func makeAnimation(widths: [Int], heights: [Int], data: [[UInt8]], animationRate: Double) -> SummerAnimation {
        return SummerAnimation(self, widths: widths, heights: heights, data: data, animationRate: animationRate)
    }
    
    /// Makes an animation out of the provided components.
    ///
    /// - Parameters:
    ///   - widths: An array containing the widths of each texture.
    ///   - heights: An array containing the heights of each texture.
    ///   - data: A 2D array containing the RGBA components for each file.
    ///   - animationRate: The amount of time in seconds for each animation frame to be shown.
    /// - Returns: An animation object.
    public func makeAnimation(widths: [Int], heights: [Int], data: [[Float]], animationRate: Double) -> SummerAnimation {
        return SummerAnimation(self, widths: widths, heights: heights, data: data, animationRate: animationRate)
    }
    
    /// Makes an animation out of the given files.
    ///
    /// - Parameters:
    ///   - files: An array of file paths to files containing image data.
    ///   - location: An optional parameter to determine if the path is relative (.inBundle) or global (.inFolder).
    ///   - animationRate: The amount of time in seconds for each animation frame to be shown.
    /// - Returns: An animation object.
    public func makeAnimation(fromFiles files: [String],
                              _ location: SummerFileLocation,
                              animationRate: Double) -> SummerAnimation? {
        return SummerAnimation(self, fromFiles: files, location, animationRate: animationRate)
    }
    
    /// Makes an animation out of the given files.
    ///
    /// - Parameters:
    ///   - files: An array of file paths to files containing image data.
    ///   - animationRate: The amount of time in seconds for each animation frame to be shown.
    /// - Returns: An animation object.
    public func makeAnimation(fromFiles files: [String], animationRate: Double) -> SummerAnimation? {
        return SummerAnimation(self, fromFiles: files, animationRate: animationRate)
    }
}
