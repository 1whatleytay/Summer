//
//  SummerMapTest.swift
//  Summer
//
//  Created by Taylor Whatley on 2018-07-12.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import SummerEngine

class SummerMapTest: SummerProgram {
    var engine: SummerEngine!
    
    var tileset: SummerTileset!
    var map: SummerMap!
    
    var myObject: SummerObject!
    
    func setup(engine: SummerEngine) {
        self.engine = engine
        
        engine.settings.messageHandler = { message in print(message) }
        
        tileset = engine.makeTileset(fromFiles: ["heroes.png", "review.png", "thousand.png"])
        
        let mapData = [
            0, 0, 0, 1,
            1, 1, 1, 2,
            2, 0, 2, 0,
            0, 1, 1, 2,
        ]
        
        map = engine.makeMap(width: 4, height: 4,
                             data: mapData,
                             tileset: tileset,
                             unitX: 10, unitY: 10)
        
        myObject = engine.makeObject(x: 0, y: 0, width: 50, height: 50, texture: engine.makeTexture(fromFile: "fourty.png")!).withTransform()
    }
    
    func update() { }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) {
        if state == .pressed {
            if key == .vkUp {
                SummerTransform.value += 1
                print(SummerTransform.value)
            } else if key == .vkDown {
                SummerTransform.value -= 1
                print(SummerTransform.value)
            }
        }
    }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) {
        if state == .movement {
            myObject.put(x: Float(x), y: Float(y))
            map.transform.setIdentity()
            map.transform.rotate(degree: Float(x / 2))
        }
    }
    
    
}
