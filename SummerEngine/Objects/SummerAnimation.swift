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
    private var tick: Int
    
    public let animationRate: Double
    
    /// Returns the texture this animation is currently displaying.
    public var currentTexture: SummerTexture {
        get { return textures[tick % textures.count] }
    }
    
    /// Moves the animation ahead a frame.
    public func step() {
        tick += 1
        for object in objects { object.texture(currentTexture) }
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
        if object._animation === self { return }
        object._animation?.removeObject(object)
        object._animation = self
        objects.append(object)
    }
    
    /// Removes an object. The object will no longer be animated.
    ///
    /// - Parameter object: The object to be removed.
    public func removeObject(_ object: SummerObject) {
        for i in 0 ..< objects.count {
            if objects[i] === object {
                objects.remove(at: i)
                object._animation = nil
            }
        }
    }
    
    /// Creates a copy of this animation.
    ///
    /// - Parameter sameTick: If true, the duplicate animation will start at the same frame as this animation.
    /// - Returns: An animation object.
    public func duplicate(sameTick: Bool = false) -> SummerAnimation {
        return SummerAnimation(parent, textures: textures, animationRate: animationRate, tick: sameTick ? tick : 0)
    }
    
    internal init(_ parent: SummerEngine, textures: [SummerTexture], animationRate: Double, tick: Int = 0) {
        self.parent = parent
        self.tick = tick
        self.animationRate = animationRate
        
        if textures.count < 1 { self.textures = [parent.makeNilTexture()] }
        else { self.textures = textures }
        
        super.init()
        
        timer = Timer.scheduledTimer(withTimeInterval: animationRate, repeats: true) { _ in self.step() }
    }
}
