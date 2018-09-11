//
//  Editor.swift
//  Editor
//
//  Created by Taylor Whatley on 2018-07-29.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import SummerEngine

class Editor: SummerEntry {
    var engine: SummerEngine!
    
    var font: AndaleMonoFont!
    var tooltip: MonoFontText!
    
    var tileset: SummerTileset!
    var map: SummerMap!
    
    var zoom: Float = 1.0/10.0
    
    public func settings() -> SummerSettings {
        var settings = SummerSettings()
        
        settings.clearColor = SummerColor.white
        
        return settings
    }
    
    public func features() -> SummerFeatures {
        var features = SummerFeatures()
        
        features.clearSettingsOnProgramSwap = true
        
        return features
    }
    
    func setup(engine: SummerEngine) {
        self.engine = engine
        
        if font == nil {
            font = AndaleMonoFont(engine)
            engine.globalResources.resources.append(font)
        }
        
        tooltip = font.makeText(text: "Tooltip here.", x: 40, y: 40, scale: 30)
        
        tileset = engine.makeTileset(tileWidth: 16, tileHeight: 16, data: [
                SummerTexture.fill(color: SummerColor(0.75, 0.75, 0.75), width: 16, height: 16),
                SummerTexture.fill(color: SummerColor(0.25, 0.25, 0.25), width: 16, height: 16)
            ])
        
        var checkered = [UInt32](repeating: 0, count: 16 * 16)
        for i in 0 ..< checkered.count {
            checkered[i] = UInt32(i % 2)
        }
        
        map = engine.makeMap(width: 16, height: 16, data: checkered, tileset: tileset, unitX: zoom, unitY: zoom)
    }
    
    func update() {
        
    }
    
    func key(key: SummerKey, characters: String?, state: SummerInputState) {
        
    }
    
    func mouse(button: SummerMouseButton, x: Double, y: Double, state: SummerInputState) {
        
    }
}
