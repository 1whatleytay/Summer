//
//  SummerInfo.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// Contains dynamic information on how the engine may behave.
public struct SummerSettings {
    /// The name of the program being run.
    public var name = "Summer Program"
    
    /// The screen width for inputs.
    public var displayWidth = 600
    /// The screen height for inputs.
    public var displayHeight = 600
    
    /// The horizontal unit for displaying. 1 is one full screen length.
    public var horizontalUnit: Float = 1/600
    /// The vertical unit for displaying. 1 is one full screen length.
    public var verticalUnit: Float = 1/600
    
    /// Changes the unit and and display sizes.
    ///
    /// - Parameters:
    ///   - width: The width of the display.
    ///   - height: The height of the display.
    public mutating func setDisplay(width: Int, height: Int) {
        displayWidth = width
        displayHeight = height
        
        horizontalUnit = 1 / Float(width)
        verticalUnit = 1 / Float(height)
    }
    
    /// A factor that can flip or stretch objects horizontally.
    public var horizontalAmp: Float = 1
    /// A factor that can flip or stretch objects vertically.
    public var verticalAmp: Float = -1
    
    /// If true and an object is created it will be initialized with its own transform.
    public var autoMakeTransformWithObject = false
    /// If true and an object is created it will be initialized with its own draw.
    public var autoMakeDrawWithObject = false
    /// If true and a map is created it will be initialized with its own transform.
    public var autoMakeTranformWithMap = false
    
    /// If true, clears all memory allocated for commit() operations each frame. Memory may need to be reallocated.
    public var conserveModifyMemory = false
    
    /// If a location is not specified while creating a texture, this value will be used.
    public var defaultTextureLocation = SummerFileLocation.bundle
    
    /// If true, SummerEngine will print allocation messages.
    public var debugPrintAllocationMessages = false
    
    /// Handles messages like failures and warnings.
    public var messageHandler: ((SummerMessage) -> Void)? = nil
    
    /// Constructor.
    public init() { }
}
