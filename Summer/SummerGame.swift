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
    
    var colorRed, colorBlue, colorGreen: SummerTexture!
    
    var red, green, blue: SummerObject!
    
    func info() -> SummerInfo {
        var info = SummerInfo()
        info.name = "Summer Game"
        info.verticalAmp = -1
        return info
    }
    
    func setup(engine: SummerEngine) {
        self.engine = engine
        
        colorRed = engine.makeTexture(fromFile: "fourty.png", .inBundle)
        colorBlue = engine.makeColor(red: 0, green: 0, blue: 1, alpha: 1)
        colorGreen = engine.makeColor(red: 0, green: 1, blue: 0, alpha: 1)
        
        red = engine.makeObject(x: 50, y: 50, width: 500, height: 500, texture: colorRed).withDraw()
        blue = engine.makeObject(x: 150, y: 150, width: 300, height: 300, texture: colorBlue).withDraw()
        green = engine.makeObject(x: 250, y: 250, width: 100, height: 100, texture: colorGreen).withDraw()
        
        blue.draw.moveForward()
        
        green.draw.moveBehind(draw: red.draw)
    }
    
    func update() {
        if engine.isKeyPressed(key: 13) { blue.y -= 2 }
        if engine.isKeyPressed(key: 0) { blue.x -= 2 }
        if engine.isKeyPressed(key: 1) { blue.y += 2 }
        if engine.isKeyPressed(key: 2) { blue.x += 2 }
        blue.save()
    }
    
    func message(message: SummerMessage) { }
    
    func key(key: UInt16, characters: String?, state: SummerInputState) { }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) { }
}
