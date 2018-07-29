//
//  SummerDraw.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-02.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import Metal

/// A class for handling groups of objects and the z-axis.
public class SummerDraw {
    private let parent: SummerEngine?
    
    private struct SummerRange {
        public var start, count: Int
        public var end: Int { return start + count - 1 }
        
        var description: String { return "(\(start)  - \(count))" }
        
        public init(start: Int, count: Int) {
            self.start = start
            self.count = count
        }
    }
    
    private var ranges = [SummerRange]()
    internal let isGlobal: Bool
    
    private func getIndexInParent() -> Int {
        if parent == nil { return -1 }
        
        var findLoc = -1
        for i in 0 ..< parent!.draws.count {
            if parent!.draws[i] === self { findLoc = i }
        }
        
        return findLoc
    }
    
    /// Activates the draw. The contents of the draw will be drawn.
    public func setActive() {
        let index = getIndexInParent()
        
        if index == -1 { parent?.draws.append(self) }
    }
    
    /// Deactivates the draw. The contents of the draw will no longer be drawn.
    public func setDeactive() {
        let index = getIndexInParent()
        
        if index != -1 { parent?.draws.remove(at: index) }
    }
    
    private func mergeConcurrentRanges(rangeIndex: Int) {
        let crange = ranges[rangeIndex]
        for i in 0 ..< ranges.count {
            if crange.start - 1 == ranges[i].end {
                ranges[i].count += crange.count
                ranges.remove(at: rangeIndex)
                break
            }
        }
        for i in 0 ..< ranges.count {
            if crange.end + 1 == ranges[i].start {
                ranges[rangeIndex].count += ranges[i].count
                ranges.remove(at: i)
                break
            }
        }
    }
    
    internal func isEmpty() -> Bool { return ranges.isEmpty }
    
    internal func addIndex(index: Int) {
        var foundRange = false
        for i in 0 ..< ranges.count {
            if ranges[i].start - 1 == index {
                ranges[i].start -= 1
                ranges[i].count += 1
                mergeConcurrentRanges(rangeIndex: i)
                foundRange = true
                break
            } else if ranges[i].end + 1 == index {
                ranges[i].count += 1
                mergeConcurrentRanges(rangeIndex: i)
                foundRange = true
                break
            } else if index > ranges[i].start && index < ranges[i].end {
                foundRange = true
                break
            }
        }
        if !foundRange {
            ranges.append(SummerRange(start: index, count: 1))
        }
    }
    
    internal func removeIndex(index: Int) {
        var hasFailed = true
        for i in 0 ..< ranges.count {
            if ranges[i].start == index {
                ranges[i].count -= 1
                ranges[i].start += 1
                if ranges[i].count <= 0 { ranges.remove(at: i) }
                hasFailed = false
            } else if ranges[i].end == index {
                ranges[i].count -= 1
                if ranges[i].count <= 0 { ranges.remove(at: i) }
                hasFailed = false
            } else if ranges[i].start < index && ranges[i].end > index {
                let tempCount = ranges[i].count
                ranges[i].count = index - ranges[i].start
                let newRange = SummerRange(
                    start: index + 1,
                    count: tempCount - (ranges[i].count + 1)
                )
                ranges.append(newRange)
                hasFailed = false
            } else { continue }
            break
        }
        if hasFailed { print("Failure!") }
    }
    
    /// Adds an object to the draw.
    ///
    /// - Parameter object: The object to add.
    public func addObject(_ object: SummerObject) { object.draw = self }
    
    /// Makes an object. The object will be part of this draw.
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
        texture: SummerTexture) -> SummerObject {
        return SummerObject(parent!,
                            draw: self,
                            x: x, y: y,
                            width: width, height: height,
                            texture: texture)
    }
    
    /// Moves this draw backwards in the z-axis.
    ///
    /// - Parameter amount: The amount of draws to move behind.
    public func moveBackwards(byAmount amount: UInt = 1) {
        let loc = getIndexInParent()
        if loc == -1 { return }
        
        let objectDraws = parent!.draws
        let newLoc = loc - Int(amount)
        
        objectDraws.remove(at: loc)
        objectDraws.insert(self, at: max(0, newLoc))
    }
    
    /// Moves this draw forwards in the z-axis.
    ///
    /// - Parameter amount: The amount of draws to move ahead of.
    public func moveForward(byAmount amount: UInt = 1) {
        let loc = getIndexInParent()
        
        let objectDraws = parent!.draws
        let newLoc = loc + Int(amount)
        
        objectDraws.remove(at: loc)
        if newLoc < objectDraws.count {
            objectDraws.insert(self, at: newLoc)
        } else {
            objectDraws.append(self)
        }
    }
    
    /// Moves this draw behind another draw.
    ///
    /// - Parameter otherDraw: The draw to be moved behind of.
    public func moveBehind(draw otherDraw: SummerDraw) {
        let loc = getIndexInParent(), otherLoc = otherDraw.getIndexInParent()
        if loc == -1 || otherLoc == -1 { return }
        
        let objectDraws = parent!.draws
        let newLoc = otherLoc - 1
        
        objectDraws.remove(at: loc)
        objectDraws.insert(self, at: max(0, newLoc))
    }
    
    /// Moved this draw ahead of another draw.
    ///
    /// - Parameter otherDraw: The draw to be moved ahead of.
    public func moveAhead(draw otherDraw: SummerDraw) {
        let loc = getIndexInParent(), otherLoc = otherDraw.getIndexInParent()
        if loc == -1 || otherLoc == -1 { return }
        
        let objectDraws = parent!.draws
        let newLoc = otherLoc + 1
        
        objectDraws.remove(at: loc)
        if newLoc < objectDraws.count {
            objectDraws.insert(self, at: newLoc)
        } else {
            objectDraws.append(self)
        }
    }
    
    /// Moves this draw to the furthest z-axis possible.
    public func moveToFurthest() {
        let loc = getIndexInParent()
        if loc == -1 { return }
        
        parent!.draws.remove(at: loc)
        parent!.draws.insert(self, at: 0)
    }
    
    /// Moves this draw to the closest z-axis possible.
    public func moveToClosest() {
        let loc = getIndexInParent()
        if loc == -1 { return }
        
        parent!.draws.remove(at: loc)
        parent!.draws.append(self)
    }
    
    internal func addDraws(encoder: MTLRenderCommandEncoder) {
        for range in ranges {
            encoder.drawPrimitives(type: .triangle,
                                         vertexStart: range.start * SummerObject.vertices,
                                         vertexCount: range.count * SummerObject.vertices)
        }
    }
    
    internal init(_ parent: SummerEngine?, isGlobal: Bool = false) {
        self.parent = parent
        self.isGlobal = isGlobal
        
        setActive()
    }
}
