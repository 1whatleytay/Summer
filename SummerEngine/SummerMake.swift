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
    public func makeObject(x: Float, y: Float,
                           width: Float, height: Float,
                           texture: SummerTexture,
                           isVisible: Bool = true) -> SummerObject {
        return SummerObject(self,
                            draw: defaultObjectDraw,
                            transform: defaultObjectTransform,
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
    ///   - animation: The animation that will animate the object.
    ///   - isVisible: If false, the object will not be shown by default.
    /// - Returns: A summer object.
    public func makeObject(x: Float, y: Float,
                           width: Float, height: Float,
                           animation: SummerAnimation,
                           isVisible: Bool = true) -> SummerObject {
        let obj = makeObject(x: x, y: y,
                             width: width, height: height,
                             texture: animation.currentTexture,
                             isVisible: isVisible)
        
        obj.animation = animation
        
        return obj
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
    public func makeDisposableObject(
        x: Float, y: Float,
        width: Float, height: Float,
        texture: SummerTexture,
        isVisible: Bool = true) -> SummerObject {
        return SummerObject(self,
                            draw: defaultObjectDraw,
                            transform: defaultObjectTransform,
                            x: x, y: y,
                            width: width, height: height,
                            texture: texture,
                            isVisible: isVisible,
                            autoDelete: false)
            .withDisposable()
    }
    
    /// Makes an object.
    ///
    /// - Parameters:
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - animation: The animation that will animate the object.
    ///   - isVisible: If false, the object will not be shown by default.
    /// - Returns: A summer object.
    public func makeDisposableObject(
        x: Float, y: Float,
        width: Float, height: Float,
        animation: SummerAnimation,
        isVisible: Bool = true) -> SummerObject {
        let obj = SummerObject(self,
                               draw: defaultObjectDraw,
                               transform: defaultObjectTransform,
                               x: x, y: y,
                               width: width, height: height,
                               texture: animation.currentTexture,
                               isVisible: isVisible,
                               autoDelete: false)
            .withDisposable()
        
        obj.animation = animation
        
        return obj
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
    public func makeEffectObject(
        x: Float, y: Float,
        width: Float, height: Float,
        texture: SummerTexture,
        isVisible: Bool = true) -> SummerObject {
        return SummerObject(self,
                            draw: defaultObjectDraw,
                            transform: defaultObjectTransform,
                            x: x, y: y,
                            width: width, height: height,
                            texture: texture,
                            isVisible: isVisible,
                            autoDelete: false)
    }
    
    /// Makes an object.
    ///
    /// - Parameters:
    ///   - x: The x position of the object.
    ///   - y: The y position of the object.
    ///   - width: The width of the object.
    ///   - height: The height of the object.
    ///   - animation: The animation that will animate the object.
    ///   - isVisible: If false, the object will not be shown by default.
    /// - Returns: A summer object.
    public func makeEffectObject(
        x: Float, y: Float,
        width: Float, height: Float,
        animation: SummerAnimation,
        isVisible: Bool = true) -> SummerObject {
        let obj = SummerObject(self,
                               draw: defaultObjectDraw,
                               transform: defaultObjectTransform,
                               x: x, y: y,
                               width: width, height: height,
                               texture: animation.currentTexture,
                               isVisible: isVisible,
                               autoDelete: false)
        
        obj.animation = animation
        
        return obj
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
        return makeTexture(width: width, height: height, data: SummerTexture.convert(data: data))
    }
    
    /// Makes a texture from an image file.
    ///
    /// - Parameters:
    ///   - file: The path to the file containing the image data.
    ///   - location: An optional parameter to determine if the path is relative (.bundle) or global (.folder).
    /// - Returns: A texture object.
    public func makeTexture(fromFile file: String,
                            in location: SummerFileLocation) -> SummerTexture? {
        guard let texdata = SummerTexture.getTextureData(fromFile: file, in: location)
            else { return nil }
        
        return makeTexture(width: texdata.width, height: texdata.height, data: texdata.data)
    }
    
    /// Makes a texture from an image file.
    ///
    /// - Parameters:
    ///   - file: The path to the file containing the image data.
    /// - Returns: A texture object.
    public func makeTexture(fromFile file: String) -> SummerTexture? {
        return makeTexture(fromFile: file, in: settings.defaultTextureLocation)
    }
    
    /// Makes a texture that represents a color.
    ///
    /// - Parameters:
    ///   - red: The red component of the color.
    ///   - green: The green component of the color.
    ///   - blue: The blue component of the color.
    ///   - alpha: The alpha component of the color.
    /// - Returns: A texture object.
    public func makeColor(red: Float, green: Float, blue: Float, alpha: Float) -> SummerTexture {
        return makeTexture(width: 1, height: 1, data: [red, green, blue, alpha])
    }
    
    /// Makes a texture that represents a color.
    ///
    /// - Parameter color: The color of the texture.
    /// - Returns: A texture object.
    public func makeColor(_ color: SummerColor) -> SummerTexture {
        return makeColor(red:Float(color.red), green: Float(color.blue), blue: Float(color.green), alpha: Float(color.alpha))
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
    ///   - alloc: The amount of extra space (in tiles) to allocate.
    /// - Returns: A tileset object.
    public func makeTileset(tileWidth: Int, tileHeight: Int, data: [[UInt8]], alloc: Int = 0) -> SummerTileset {
        return SummerTileset(self, tileWidth: tileWidth, tileHeight: tileHeight, data: data, alloc: alloc)
    }
    
    /// Makes a tileset out of the given components.
    ///
    /// - Parameters:
    ///   - tileWidth: The width of each tile.
    ///   - tileHeight: The height of each tile.
    ///   - data: A 2D array containing the RGBA components of each tile.
    ///   - alloc: The amount of extra space (in tiles) to allocate.
    /// - Returns: A tileset object.
    public func makeTileset(tileWidth: Int, tileHeight: Int, data: [[Float]], alloc: Int = 0) -> SummerTileset {
        return makeTileset(tileWidth: tileWidth, tileHeight: tileHeight,
                           data: SummerTileset.convert(data: data),
                           alloc: alloc)
    }
    
    /// Makes a tileset out the given files.
    ///
    /// - Parameters:
    ///   - files: An array of file paths to files containing image data.
    ///   - location: An optional parameter to determine if the path is relative (.bundle) or global (.folder).
    ///   - alloc: The amount of extra space (in tiles) to allocate.
    /// - Returns: A tileset object.
    public func makeTileset(fromFiles files: [String], in location: SummerFileLocation, alloc: Int = 0) -> SummerTileset? {
        guard let tilesetdata = SummerTileset.getTilesetData(fromFiles: files, in: location)
            else {
                settings.messageHandler?(.couldNotLoadTileset)
                return nil
        }
        
        return makeTileset(tileWidth: tilesetdata.tileWidths[0], tileHeight: tilesetdata.tileHeights[0],
                           data: tilesetdata.data, alloc: alloc)
    }
    
    /// Makes a tileset out of the given files.
    ///
    /// - Parameters:
    ///   - files: An array of file paths to files containing image data.
    ///   - alloc: The amount of extra space (in tiles) to allocate.
    /// - Returns: A tileset object.
    public func makeTileset(fromFiles files: [String], alloc: Int = 0) -> SummerTileset? {
        return makeTileset(fromFiles: files, in: settings.defaultTextureLocation, alloc: alloc)
    }
    
    /// Makes a map.
    ///
    /// - Parameters:
    ///   - width: The width of the map in tiles.
    ///   - height: The height of the map in tiles.
    ///   - data: An array of indices into the tileset. Each value is one tile in the map.
    ///   - tileset: A tileset containing images for each tile in the map.
    ///   - transform: A transform for moving the map.
    ///   - unitX: A fraction representing how much of the screen one tile should take horizontally.
    ///   - unitY: A fraction representing how much of the screen one tile should take vertically.
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
    ///   - unitX: A fraction representing how much of the screen one tile should take horizontally.
    ///   - unitY: A fraction representing how much of the screen one tile should take vertically.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
    public func makeMap(width: Int, height: Int,
                        data: [UInt32],
                        tileset: SummerTileset,
                        unitX: Float, unitY: Float,
                        final: Bool = false) -> SummerMap {
        return makeMap(width: width, height: height, data: data,
                       tileset: tileset,
                       transform: defaultMapTransform,
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
    ///   - unitX: A fraction representing how much of the screen one tile should take horizontally.
    ///   - unitY: A fraction representing how much of the screen one tile should take vertically.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
    public func makeMap(width: Int, height: Int,
                        data: [Int],
                        tileset: SummerTileset,
                        transform: SummerTransform,
                        unitX: Float, unitY: Float,
                        final: Bool = false) -> SummerMap {
        var subdata = [UInt32](repeating: 0, count: data.count)
        
        for i in 0 ..< data.count { subdata[i] = UInt32(data[i]) }
        
        return makeMap(width: width, height: height, data: subdata,
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
    ///   - unitX: A fraction representing how much of the screen one tile should take horizontally.
    ///   - unitY: A fraction representing how much of the screen one tile should take vertically.
    ///   - final: If true, the map will be constant.
    /// - Returns: A map object.
    public func makeMap(width: Int, height: Int,
                        data: [Int],
                        tileset: SummerTileset,
                        unitX: Float, unitY: Float,
                        final: Bool = false) -> SummerMap {
        return makeMap(width: width, height: height, data: data,
                       tileset: tileset,
                       transform: defaultMapTransform,
                       unitX: unitX, unitY: unitY,
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
        var textures = [SummerTexture](repeating: makeNilTexture(), count: data.count)
        for i in 0 ..< textures.count {
            textures[i] = makeTexture(width: widths[i], height: heights[i], data: data[i])
        }
        
        return makeAnimation(textures: textures, animationRate: animationRate)
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
        var textures = [SummerTexture](repeating: makeNilTexture(), count: data.count)
        for i in 0 ..< textures.count {
            textures[i] = makeTexture(width: widths[i], height: heights[i], data: data[i])
        }
        
        return makeAnimation(textures: textures, animationRate: animationRate)
    }
    
    /// Makes an animation out of the given files.
    ///
    /// - Parameters:
    ///   - files: An array of file paths to files containing image data.
    ///   - location: An optional parameter to determine if the path is relative (.bundle) or global (.folder).
    ///   - animationRate: The amount of time in seconds for each animation frame to be shown.
    /// - Returns: An animation object.
    public func makeAnimation(fromFiles files: [String],
                              in location: SummerFileLocation,
                              animationRate: Double) -> SummerAnimation? {
        guard let tiles = SummerTileset.getTilesetData(fromFiles: files, in: location)
            else { return nil }
        
        return makeAnimation(widths: tiles.tileWidths, heights: tiles.tileHeights,
                             data: tiles.data, animationRate: animationRate)
    }
    
    /// Makes an animation out of the given files.
    ///
    /// - Parameters:
    ///   - files: An array of file paths to files containing image data.
    ///   - animationRate: The amount of time in seconds for each animation frame to be shown.
    /// - Returns: An animation object.
    public func makeAnimation(fromFiles files: [String], animationRate: Double) -> SummerAnimation? {
        return makeAnimation(fromFiles: files, in: settings.defaultTextureLocation, animationRate: animationRate)
    }
}
