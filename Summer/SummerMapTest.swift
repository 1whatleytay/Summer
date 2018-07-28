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
                             unitX: 50/600, unitY: 50/600).withTransform()
        
        myObject = engine.makeObject(x: 0, y: 0, width: 50, height: 50, texture: engine.makeTexture(fromFile: "fourty.png")!).withTransform(map.transform)
    }
    
    func update() { }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) { }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) {
        if state == .movement {
            map.transform.setOffset(x: Float(x), y: Float(y))
            map.transform.setOrigin(x: Float(x), y: Float(y))
            map.transform.setIdentity()
            map.transform.rotate(degree: Float(x / 10))
        }
    }
    
    
}
