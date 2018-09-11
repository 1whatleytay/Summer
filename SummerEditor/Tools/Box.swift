//
//  Box.swift
//  SummerEditor
//
//  Created by Taylor Whatley on 2018-08-20.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import SummerEngine

class Box: SummerResource {
    private var engine: SummerEngine
    
    private var walls = [SummerObject]()
    private var boxColor: SummerTexture
    
    public var x, y, width, height: Float
    public var thickness: Float
    
    private var _color: SummerColor
    public var color: SummerColor {
        get { return _color }
        set {
            _color = newValue
            boxColor = engine.makeColor(newValue)
            save()
        }
    }
    
    public func save() {
        walls = [
            engine.makeObject(x: x, y: y, width: width, height: thickness, texture: boxColor),
            engine.makeObject(x: x + width - thickness, y: y, width: thickness, height: height, texture: boxColor),
            engine.makeObject(x: x, y: y + height - thickness, width: width, height: thickness, texture: boxColor),
            engine.makeObject(x: x, y: y, width: thickness, height: height, texture: boxColor)
        ]
    }
    
    func resourceList() -> SummerResourceList {
        return SummerResourceList(objects: walls, textures: [boxColor])
    }
    
    init(_ engine: SummerEngine, x: Float, y: Float, width: Float, height: Float, color: SummerColor, thickness: Float = 6) {
        self.engine = engine
        
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.thickness = thickness
        
        self._color = color
        self.boxColor = engine.makeColor(color)
        
        save()
    }
}
