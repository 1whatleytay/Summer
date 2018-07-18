//
//  SummerInfo.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

public struct SummerSettings {
    public var name = "Summer Program"
    
    public var displayWidth = 600, displayHeight = 600
    public var horizontalUnit: Float = 1/600, verticalUnit: Float = 1/600
    
    public mutating func setDisplay(width: Int, height: Int) {
        displayWidth = width
        displayHeight = height
        
        horizontalUnit = 1 / Float(width)
        verticalUnit = 1 / Float(height)
    }
    
    public var verticalAmp: Float = 1, horizontalAmp: Float = 1
    
    public var deleteObjectsOnDealloc = false
    public var deleteTexturesOnDealloc = false
    public var deleteTransformsOnDealloc = false
    
    public var autoMakeTransformWithObject = false
    public var autoMakeDrawWithObject = false
    public var autoMakeTranformWithMap = false
    
    public var conserveModifyMemory = false
    
    public var defaultTextureLocation = SummerFileLocation.inBundle
    
    public var debugPrintAllocationMessages = false
    
    public init() { }
}
