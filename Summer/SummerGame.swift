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
    
    func setup(engine: SummerEngine) {
        self.engine = engine
        
        engine.settings.messageHandler = { message in print(message) }
        
        colorRed = engine.makeTexture(fromFile: "fourty.png")
        colorBlue = engine.makeColor(red: 0, green: 0, blue: 1, alpha: 1)
        colorGreen = engine.makeColor(red: 0, green: 1, blue: 0, alpha: 1)
        
        red = engine.makeObject(x: 50, y: 50, width: 500, height: 500, texture: colorRed).withTransform()
        blue = engine.makeObject(x: 150, y: 150, width: 300, height: 300, texture: colorBlue)
        green = engine.makeObject(x: 250, y: 250, width: 100, height: 100, texture: colorGreen, isVisible: false)
    }
    
    func update() {
        if engine.isKeyPressed(key: .vkW) { blue.y -= 2 }
        if engine.isKeyPressed(key: .vkA) { blue.x -= 2 }
        if engine.isKeyPressed(key: .vkS) { blue.y += 2 }
        if engine.isKeyPressed(key: .vkD) { blue.x += 2 }
        blue.save()
        
        red.transform.rotate(degree: 1)
    }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) {
        if state == .pressed {
            switch key {
            case .vkReturn:
                engine.swapPrograms(SummerMenu(red), keep: SummerResourceList(objects: [red]))
            case .vkL:
                green.isVisible = !green.isVisible
            default:
                break
            }
        }
    }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) { }
}

class SummerMenu: SummerProgram {
    var engine: SummerEngine!
    
    var obj: SummerObject!
    
    var tex: SummerTexture!
    
    func allocObjects(count: Int) {
        print("Allocating...")
        for _ in 0 ..< count {
            _ = engine.makeObject(x: 0, y: 0, width: 0, height: 0, texture: tex)
        }
    }
    
    func setup(engine: SummerEngine) {
        self.engine = engine
        
        tex = engine.makeColor(red: 1, green: 0, blue: 0, alpha: 1)
        
        allocObjects(count: 30)
    }
    
    func update() {
        obj.move(x: 1, y: 0)
    }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) { }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) { }
    
    init(_ obj: SummerObject) {
        self.obj = obj
    }
}
