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
        
        let data: [[Float]] = [[1, 1, 1, 1]]
        tileset = engine.makeTileset(tileWidth: 1, tileHeight: 1, data: data)
        
        let mapData = [ 0 ]
        
        map = engine.makeMap(width: 1, height: 1,
                             data: mapData,
                             tileset: tileset,
                             unitX: 1, unitY: 1).withTransform()
        
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
