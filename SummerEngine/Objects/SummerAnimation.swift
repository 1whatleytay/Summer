//
//  SummerAnimation.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-14.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation

public class SummerAnimation: NSObject {
    private let parent: SummerEngine
    
    private let textures: [SummerTexture]
    private var objects = [SummerObject]()
    
    private var timer: Timer!
    private var tick = 0
    
    public func step() {
        print(tick)
        tick += 1
        let texture = textures[tick % textures.count]
        for object in objects { object.texture(texture) }
    }
    
    private func callStep(t: Timer) { step() }
    
    public func changeRate(newRate rate: Double) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: rate, repeats: true, block: callStep)
    }
    
    public func addObject(_ object: SummerObject) {
        if object.animation === self { return }
        object.animation?.removeObject(object)
        object.animation = self
        objects.append(object)
    }
    
    public func removeObject(_ object: SummerObject) {
        for i in 0 ..< objects.count {
            if objects[i] === object {
                objects.remove(at: i)
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
