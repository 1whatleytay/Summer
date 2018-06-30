//
//  SummerProgram.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

public enum SummerInputState {
    case pressed
    case released
    case movement
}

public enum SummerMouseButton {
    case left
    case right
    case other
    case movement
}

public protocol SummerProgram {
    func info() -> SummerInfo
    
    func setup(engine: SummerEngine)
    func update()
    
    func message(message: SummerMessage)
    
    func key(key: UInt16, characters: String?, state: SummerInputState)
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState)
}
