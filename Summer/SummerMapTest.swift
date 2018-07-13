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
        
        tileset = engine.makeTileset(fromFiles: [
            "/Users/desgroup/Desktop/heroes.png",
            "/Users/desgroup/Desktop/review.png",
            "/Users/desgroup/Desktop/thousand.png"
            ], .inFolder)
        
        let mapData: [UInt32] = [
            0, 0, 0, 1,
            1, 1, 1, 2,
            2, 0, 2, 0,
            0, 1, 1, 2,
        ]
        
        map = engine.makeMap(width: 4, height: 4,
                             data: mapData,
                             tileset: tileset,
                             unitX: 200, unitY: 200,
                             mapType: .dynamicMap)
        
        map.setCurrent()
        
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
        }
    }
    
    
}
