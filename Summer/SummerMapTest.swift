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
        
        engine.settings.verticalAmp = -1
        
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
                             unitX: 200, unitY: 200,
                             final: true).withTransform()
        
        map.transform.moveOffset(x: 100, y: 100)
        map.transform.setOrigin(x: 150, y: 150)
        
        map.setActive()
        
        myObject = engine.makeObject(x: 0, y: 0, width: 50, height: 50, texture: engine.makeTexture(fromFile: "fourty.png", .inBundle)!)
    }
    
    func update() {
        if (engine.isKeyPressed(key: .vkW)) { myObject.move(x: 0, y: -1) }
        if (engine.isKeyPressed(key: .vkA)) { myObject.move(x: -1, y: 0) }
        if (engine.isKeyPressed(key: .vkS)) { myObject.move(x: 0, y: 1) }
        if (engine.isKeyPressed(key: .vkD)) { myObject.move(x: 1, y: 0) }
    }
    
    func message(message: SummerMessage) {
        print(message)
    }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) {
        
    }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) {
        if state == .movement {
            myObject.put(x: Float(x), y: Float(y))
            map.transform.setIdentity()
            map.transform.rotate(degree: Float(x / 2))
        }
    }
    
    
}
