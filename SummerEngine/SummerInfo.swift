//
//  SummerInfo.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

public struct SummerInfo {
    public var name = "Summer Program"
    
    public var maxObjects = 200
    public var textureAllocWidth = 1000, textureAllocHeight = 1000
    
    public var verticalUnit: Float = 1/600, horizontalUnit: Float = 1/600
    public var verticalAmp: Float = 1, horizontalAmp: Float = 1
    
    public var deleteTexturesOnDealloc = false, deleteObjectsOnDealloc = false
    
    public var subscribeToEvents = true
    
    public var transparency = false
    
    public init() {}
}
