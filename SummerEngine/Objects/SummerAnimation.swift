//
//  SummerAnimation.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-14.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation

/// Customizable animation for objects.
public class SummerAnimation: NSObject {
    private let parent: SummerEngine
    
    private let textures: [SummerTexture]
    private var objects = [SummerObject]()
    
    private var timer: Timer!
    private var tick = 0
    
    /// Moves the animation ahead a frame.
    public func step() {
        print(tick)
        tick += 1
        let texture = textures[tick % textures.count]
        for object in objects { object.texture(texture) }
    }
    
    private func callStep(t: Timer) { step() }
    
    /// Changes the rate of the animation.
    ///
    /// - Parameter rate: The new animation rate, in seconds.
    public func changeRate(newRate rate: Double) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: rate, repeats: true, block: callStep)
    }
    
    /// Adds an object to be animated.
    ///
    /// - Parameter object: The object to be animated.
    public func addObject(_ object: SummerObject) {
        if object.animation === self { return }
        object.animation?.removeObject(object)
        object.animation = self
        objects.append(object)
    }
    
    /// Removes an object. The object will no longer be animated.
    ///
    /// - Parameter object: The object to be removed.
    public func removeObject(_ object: SummerObject) {
        for i in 0 ..< objects.count {
            if objects[i] === object {
                objects.remove(at: i)
                object.animation = nil
            }
        }
    }
    
    internal init(_ parent: SummerEngine, textures: [SummerTexture], animationRate: Double) {
        self.parent = parent
        self.textures = textures
        
        super.init()
        
        timer = Timer.scheduledTimer(withTimeInterval: animationRate, repeats: true) { _ in self.step() }
    }
    
    internal convenience init(_ parent: SummerEngine,
                              widths: [Int], heights: [Int],
                              data: [[UInt8]],
                              animationRate: Double) {
        var textures = [SummerTexture](repeating: parent.makeNilTexture(), count: data.count)
        for i in 0 ..< textures.count {
            textures[i] = parent.makeTexture(width: widths[i], height: heights[i], data: data[i])
        }
        
        self.init(parent, textures: textures, animationRate: animationRate)
    }
    
    internal convenience init(_ parent: SummerEngine,
                              widths: [Int], heights: [Int],
                              data: [[Float]],
                              animationRate: Double) {
        var textures = [SummerTexture](repeating: parent.makeNilTexture(), count: data.count)
        for i in 0 ..< textures.count {
            textures[i] = parent.makeTexture(width: widths[i], height: heights[i], data: data[i])
        }
        
        self.init(parent, textures: textures, animationRate: animationRate)
    }
    
    internal convenience init?(_ parent: SummerEngine,
                               fromFiles files: [String],
                               _ location: SummerFileLocation,
                               animationRate: Double) {
        guard let tiles = SummerTileset.getTilesetData(fromFiles: files, location)
            else { return nil }
        
        self.init(parent, widths: tiles.tileWidths, heights: tiles.tileHeights, data: tiles.data, animationRate: animationRate)
    }
    
    internal convenience init?(_ parent: SummerEngine,
                               fromFiles files: [String],
                               animationRate: Double) {
        self.init(parent, fromFiles: files, parent.settings.defaultTextureLocation, animationRate: animationRate)
    }
}
