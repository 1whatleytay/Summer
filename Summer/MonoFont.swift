//
//  Font.swift
//  Editor
//
//  Created by Taylor Whatley on 2018-08-03.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Foundation
import SummerEngine

class MonoFontText {
    private let parent: MonoFont
    private let engine: SummerEngine
    
    private var textObjects: [SummerObject?]
    private let charWidth, charHeight: Float
    
    private var _transform: SummerTransform
    public var transform: SummerTransform {
        get { return _transform }
        set {
            for object in textObjects {
                object?.transform = newValue
            }
        }
    }
    
    @discardableResult public func makeTransform() -> SummerTransform {
        transform = engine.makeTransform()
        
        return _transform
    }
    
    public func withTransform() -> MonoFontText {
        makeTransform()
        
        return self
    }
    
    public func delete() {
        for object in textObjects {
            object?.delete()
        }
    }
    
    fileprivate init(_ parent: MonoFont, text: String, x: Float, y: Float, scale: Float = 1, alloc: Int = 0) {
        self.parent = parent
        self.engine = parent.parent
        
        self._transform = engine.globalTransform
        
        textObjects = [SummerObject?](repeating: nil, count: text.count + alloc)
        
        let peri = Float(parent.charWidth + parent.charHeight)
        
        charWidth = Float(parent.charWidth) / peri * scale
        charHeight = Float(parent.charHeight) / peri * scale
        
        for i in 0 ..< text.count {
            textObjects[i] = engine.makeObject(x: x + charWidth * Float(i), y: y,
                                                      width: charWidth, height: charHeight,
                                                      texture: parent.characters[
                                                        parent.idFunc(
                                                            text[text.index(
                                                                text.startIndex, offsetBy: i)])])
        }
        self._transform = engine.globalTransform
    }
}

class MonoFont {
    fileprivate let parent: SummerEngine
    
    public let texture: SummerTexture
    
    fileprivate var characters: [SummerTexture]
    fileprivate let idFunc: (Character) -> Int
    fileprivate let charWidth, charHeight: Int
    
    public func makeText(text: String, x: Float, y: Float, scale: Float = 1, alloc: Int = 0) -> MonoFontText {
        return MonoFontText(self, text: text, x: x, y: y, scale: scale, alloc: alloc)
    }
    
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
                characters[x + y * gridWidth] = texture.sample(x: charWidth * x, y: charHeight * y, width: charWidth, height: charHeight)!
            }
        }
    }
}
