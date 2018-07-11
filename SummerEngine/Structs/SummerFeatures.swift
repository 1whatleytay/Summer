//
//  SummerFeatures.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-10.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation

public struct SummerFeatures {
    public var maxObjects = 200
    public var maxTransforms = 60
    public var textureAllocWidth = 1000, textureAllocHeight = 1000
    
    public var staticPivot = false, staticTransform = false
    
    public var subscribeToEvents = true
    public var transparency = false
    
    public var clearSettingsOnProgramSwap = false
    
    public init() { }
}
