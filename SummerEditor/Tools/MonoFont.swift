//
//  Font.swift
//  Editor
//
//  Created by Taylor Whatley on 2018-08-03.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import SummerEngine

class MonoFontText: SummerResource {
    private let parent: MonoFont
    private let engine: SummerEngine
    
    private var textObjects: [SummerObject?]
    private let charWidth, charHeight: Float
    
    public var x, y: Float
    
    private var _transform: SummerTransform
    public var transform: SummerTransform {
        get { return _transform }
        set {
            for object in textObjects {
                object?.transform = newValue
            }
            _transform = newValue
        }
    }
    
    private var _draw: SummerDraw
    public var draw: SummerDraw {
        get { return _draw }
        set {
            for object in textObjects {
                object?.draw = newValue
            }
            _draw = newValue
        }
    }
    
    private var _text: String
    public var text: String {
        get { return _text }
        set {
            delete()
            
            if text.count > textObjects.count { textObjects.reserveCapacity(text.count) }
            
            save()
        }
    }
    
    func resourceList() -> SummerResourceList { return SummerResourceList(objects: textObjects) }
    
    @discardableResult public func makeTransform() -> SummerTransform {
        transform = engine.makeTransform()
        
        return _transform
    }
    
    public func withTransform() -> MonoFontText {
        makeTransform()
        
        return self
    }
    
    public func move(x: Float, y: Float) {
        self.x += x
        self.y += y
        
        save()
    }
    
    public func put(x: Float, y: Float) {
        self.x += x
        self.y += y
        
        save()
    }
    
    public func save() {
        for i in 0 ..< text.count {
            textObjects[i] = _draw.makeObject(x: x + charWidth * Float(i), y: y,
                                               width: charWidth, height: charHeight,
                                               texture: parent.characters[
                                                parent.idFunc(
                                                    text[text.index(
                                                        text.startIndex, offsetBy: i)])])
                .withTransform(_transform)
        }
    }
    
    public func delete() {
        for object in textObjects {
            object?.delete()
        }
    }
    
    fileprivate init(_ parent: MonoFont, text: String, x: Float, y: Float, scale: Float = 1, alloc: Int = 0) {
        self.parent = parent
        self.engine = parent.parent
        
        self.x = x
        self.y = y
        self._text = text
        self._transform = engine.makeTransform()
        self._draw = engine.makeDraw()
        
        _draw.filter = .linear
        
        textObjects = [SummerObject?](repeating: nil, count: text.count + alloc)
        
        let peri = Float(parent.charWidth + parent.charHeight)
        
        charWidth = Float(parent.charWidth) / peri * scale
        charHeight = Float(parent.charHeight) / peri * scale
        
        save()
    }
}

class MonoFont: SummerResource {
    fileprivate let parent: SummerEngine
    
    public let texture: SummerTexture
    
    fileprivate var characters: [SummerTexture]
    fileprivate let idFunc: (Character) -> Int
    fileprivate let charWidth, charHeight: Int
    
    func resourceList() -> SummerResourceList { return SummerResourceList(textures: [texture]) }
    
    public func makeText(text: String, x: Float, y: Float, scale: Float = 1, alloc: Int = 0) -> MonoFontText {
        return MonoFontText(self, text: text, x: x, y: y, scale: scale, alloc: alloc)
    }
    
    public func delete() { texture.delete() }
    
    public init?(_ parent: SummerEngine,
                 fromFile file: String,
                 gridWidth: Int, gridHeight: Int,
                 idFunc: @escaping (Character) -> Int) {
        self.parent = parent
        self.idFunc = idFunc
        
        if let tex = parent.makeTexture(fromFile: file) { texture = tex } else { return nil }
        let size = texture.getSize()
        charWidth = size.width / gridWidth
        charHeight = size.height / gridHeight
        
        characters = [SummerTexture](repeating: parent.makeNilTexture(), count: gridWidth * gridHeight)
        
        for x in 0 ..< gridWidth {
            for y in 0 ..< gridHeight {
                characters[x + y * gridWidth] = texture.sample(x: charWidth * x, y: charHeight * y, width: charWidth, height: charHeight)
            }
        }
    }
}
