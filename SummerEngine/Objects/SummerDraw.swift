//
//  SummerDraw.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-02.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import Metal

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
        for i in 0 ..< parent!.objectDraws.count {
            if parent!.objectDraws[i] === self { findLoc = i }
        }
        
        return findLoc
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
            }
        }
        if !foundRange {
            ranges.append(SummerRange(start: index, count: 1))
        }
    }
    
    internal func removeIndex(index: Int) {
        for i in 0 ..< ranges.count {
            if ranges[i].start == index {
                ranges[i].count -= 1
                ranges[i].start += 1
                if ranges[i].count <= 0 { ranges.remove(at: i) }
            } else if ranges[i].end == index {
                ranges[i].count -= 1
                if ranges[i].count <= 0 { ranges.remove(at: i) }
            } else if ranges[i].start < index && ranges[i].end > index {
                let tempCount = ranges[i].count
                ranges[i].count = index - ranges[i].start
                let newRange = SummerRange(
                    start: index + 1,
                    count: tempCount - (ranges[i].count + 1)
                )
                ranges.append(newRange)
            } else { continue }
            break
        }
    }
    
    public func addObject(object: SummerObject) { object.setDraw(to: self) }
    
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
    
    public func moveBackwards(byAmount amount: UInt = 1) {
        let loc = getIndexInParent()
        if loc == -1 { return }
        
        let objectDraws = parent!.objectDraws
        let newLoc = loc - Int(amount)
        
        objectDraws.remove(at: loc)
        objectDraws.insert(self, at: max(0, newLoc))
    }
    
    public func moveForward(byAmount amount: UInt = 1) {
        let loc = getIndexInParent()
        
        let objectDraws = parent!.objectDraws
        let newLoc = loc + Int(amount)
        
        objectDraws.remove(at: loc)
        if newLoc < objectDraws.count {
            objectDraws.insert(self, at: newLoc)
        } else {
            objectDraws.append(self)
        }
    }
    
    public func moveBehind(draw otherDraw: SummerDraw) {
        let loc = getIndexInParent(), otherLoc = otherDraw.getIndexInParent()
        if loc == -1 || otherLoc == -1 { return }
        
        let objectDraws = parent!.objectDraws
        let newLoc = otherLoc - 1
        
        objectDraws.remove(at: loc)
        objectDraws.insert(self, at: max(0, newLoc))
    }
    
    public func moveAhead(draw otherDraw: SummerDraw) {
        let loc = getIndexInParent(), otherLoc = otherDraw.getIndexInParent()
        if loc == -1 || otherLoc == -1 { return }
        
        let objectDraws = parent!.objectDraws
        let newLoc = otherLoc + 1
        
        objectDraws.remove(at: loc)
        if newLoc < objectDraws.count {
            objectDraws.insert(self, at: newLoc)
        } else {
            objectDraws.append(self)
        }
    }
    
    public func moveToFurthest() {
        let loc = getIndexInParent()
        if loc == -1 { return }
        
        parent!.objectDraws.remove(at: loc)
        parent!.objectDraws.insert(self, at: 0)
    }
    
    public func moveToClosest() {
        let loc = getIndexInParent()
        if loc == -1 { return }
        
        parent!.objectDraws.remove(at: loc)
        parent!.objectDraws.append(self)
    }
    
    internal func addDraws(encoder: MTLRenderCommandEncoder) {
        for range in ranges {
            encoder.drawPrimitives(type: .triangle,
                                         vertexStart: range.start * SummerObject.vertices,
                                         vertexCount: range.count * SummerObject.vertices)
        }
    }
    
    public func delete() {
        if parent == nil { return }
        
        var findLoc = -1
        for i in 0 ..< parent!.objectDraws.count {
            if parent!.objectDraws[i] === self { findLoc = i }
        }
        
        if findLoc != -1 { parent!.objectDraws.remove(at: findLoc) }
    }
    
    internal init(_ parent: SummerEngine?, isGlobal: Bool = false) {
        self.parent = parent
        self.isGlobal = isGlobal
        
        parent?.objectDraws.append(self)
    }
}
