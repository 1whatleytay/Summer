//
//  SummerGame.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-23.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import SummerEngine

class SummerGame: SummerProgram {
    var engine: SummerEngine!
    
    var colorRed: SummerTexture!
    var colorBlue: SummerTexture!
    
    var myObject: SummerObject!
    var mySecondObject: SummerObject!
    
    func info() -> SummerInfo {
        var info = SummerInfo()
        info.name = "Summer Game"
        info.verticalAmp = -1
        return info
    }
    
    func setup(engine: SummerEngine) {
        self.engine = engine
        
        let texData: [Float] = [
            0, 0, 1, 1, 1, 1, 0, 0.5,
            1, 0, 0, 0.5, 0, 1, 0, 0.5,
        ]
        
        colorRed = engine.makeTexture(width: 2, height: 2, data: texData)
        colorBlue = engine.makeColor(red: 0, green: 0, blue: 1, alpha: 1)
        
        mySecondObject = engine.makeObject(x: 400, y: 400, width: 20, height: 20, texture: colorBlue)
        myObject = engine.makeObject(x: 0, y: 0, width: 300, height: 300, texture: colorRed)
    }
    
    func update() {
        myObject.move(x: 1, y: myObject.x * myObject.x)
    }
    
    func message(message: SummerMessage) {
        switch message {
        default: break
        }
    }
    
    func key() {
        
    }
}
