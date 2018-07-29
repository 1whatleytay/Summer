//
//  SummerFeatures.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-07-10.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation

/// Contains initialization information for the engine.
public struct SummerFeatures {
    /// The maximum amount of objects.
    public var maxObjects = 200
    /// The maximum amount of transforms.
    public var maxTransforms = 200
    /// The allocation width of the main texture.
    public var textureAllocWidth = 1000
    /// The allocation height of the main texture.
    public var textureAllocHeight = 1000
    
    /// If true, pivot operations may be slower to conserve shared memory.
    public var staticPivot = true
    /// If true, transform saves may be slower to conserve shared memory.
    public var staticTransform = false
    
    /// If true, SummerEngine will subscribe to input events from the view.
    public var subscribeToEvents = true
    /// If true, SummerEngine will enable blending.
    public var transparency = true
    
    /// If true, SummerEngine will reset its settings each time a program is changed.
    public var clearSettingsOnProgramSwap = false
    
    /// If true, the default metal library will be used.
    public var useDefaultLibrary = false
    
    /// Constructor.
    public init() { }
}
