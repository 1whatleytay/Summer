//
//  Editor.swift
//  Editor
//
//  Created by Taylor Whatley on 2018-07-29.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import SummerEngine

class Editor: SummerProgram {
    
    func setup(engine: SummerEngine) {
        
        _ = engine.makeObject(x: 0, y: 0, width: 600, height: 600, texture: engine.makeColor(red: 1, green: 1, blue: 1, alpha: 1))
        
        let font = AndaleMonoFont(engine)
        _ = font.makeText(text: "This is test text :D @desgroup <html></html>", x: 0, y: 0, scale: 30)
    }
    
    func update() {
        
    }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) {
        
    }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) {
        
    }
}
