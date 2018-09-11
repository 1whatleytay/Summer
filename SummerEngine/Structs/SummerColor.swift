//
//  SummerColor.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-08-20.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Metal

public struct SummerColor {
    public var red, green, blue, alpha: Float
    
    public var data: [UInt8] {
        get {
            return [
                UInt8(red * 256),
                UInt8(green * 256),
                UInt8(blue * 256),
                UInt8(alpha * 256)
            ]
        }
    }
    
    internal func makeClearColor() -> MTLClearColor {
        return MTLClearColorMake(Double(red), Double(green), Double(blue), Double(alpha))
    }
    
    public static let white = SummerColor(1, 1, 1)
    public static let black = SummerColor(0, 0, 0)
    public static let red = SummerColor(1, 0, 0)
    public static let green = SummerColor(0, 1, 0)
    public static let blue = SummerColor(0, 0, 1)
    public static let yellow = SummerColor(1, 1, 0)
    public static let aqua = SummerColor(0, 1, 1)
    public static let purple = SummerColor(1, 0, 1)
    public static let clear = SummerColor(0, 0, 0, 0)
    
    public init(_ red: Float, _ green: Float, _ blue: Float, _ alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init(_ red: Float, _ green: Float, _ blue: Float) {
        self.init(red, green, blue, 1)
    }
}
