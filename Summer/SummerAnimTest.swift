//
//  SummerAnimTest.swift
//  Summer
//
//  Created by Taylor Whatley on 2018-07-14.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import SummerEngine

class SummerAnimTest: SummerProgram {
    var engine: SummerEngine!
    
    var animation: SummerAnimation!
    var obj: SummerObject!
    
    func setup(engine: SummerEngine) {
        self.engine = engine
        
        animation = engine.makeAnimation(
            fromFiles: ["myguy1.png", "myguy2.png", "myguy1.png", "myguy3.png"],
            animationRate: 0.5)
        obj = engine.makeObject(x: 0, y: 0, width: 300, height: 300, texture: engine.makeNilTexture())
        
        obj.setAnimation(animation: animation)
    }
    
    func update() {
        
    }
    
    func message(message: SummerMessage) {
        
    }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) {
        
    }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) {
        
    }
}
