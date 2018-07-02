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
        
        colorRed = engine.makeTexture(fromFile: "fourty.png", .inBundle)
        if colorRed == nil { exit(1) }
        colorBlue = engine.makeColor(red: 0, green: 0, blue: 1, alpha: 1)
        
        myObject = engine.makeObject(x: 400, y: 400, width: 20, height: 20, texture: colorBlue)
        mySecondObject = engine.makeObject(x: 0, y: 0, width: 300, height: 300, texture: colorRed)
    }
    
    func update() {
        if engine.isKeyPressed(key: 13) { mySecondObject.y -= 2 }
        if engine.isKeyPressed(key: 0) { mySecondObject.x -= 2 }
        if engine.isKeyPressed(key: 1) { mySecondObject.y += 2 }
        if engine.isKeyPressed(key: 2) { mySecondObject.x += 2 }
        mySecondObject.save()
    }
    
    func message(message: SummerMessage) { }
    
    func key(key: UInt16, characters: String?, state: SummerInputState) { }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) { }
}
