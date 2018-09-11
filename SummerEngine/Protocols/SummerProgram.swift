//
//  SummerProgram.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-22.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

/// The interface between the engine and the application.
public protocol SummerProgram: class {
    /// Called once to make sure the program is set up and ready for execution.
    ///
    /// - Parameter engine: The engine instance that will be running the program.
    func setup(engine: SummerEngine)
    
    /// Called many times a second to update the scene.
    func update()
    
    /// Called once a key has been pressed or released.
    ///
    /// - Parameters:
    ///   - key: The key code of the key that was pressed or released.
    ///   - characters: The characters that were typed.
    ///   - state: The state of the key. Either .pressed or .released.
    func key(key: SummerKey, characters: String?, state: SummerInputState)
    
    /// Called once a mouse button has been pressed or released or if the cursor has moved.
    ///
    /// - Parameters:
    ///   - button: The button that was pressed. If the cursor has moved, it is set to .movement.
    ///   - x: The x location of the cursor.
    ///   - y: The y location of the cursor.
    ///   - state: The state of the mouse button. Either .pressed or .released. If the cursor has moved, it is set to .movement.
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState)
}
