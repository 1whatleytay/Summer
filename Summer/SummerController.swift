//
//  ViewController.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-16.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Cocoa
import MetalKit
import SummerEngine

class SummerController: NSViewController {
    @IBOutlet var summerView: SummerView!
    
    var engine: SummerEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var features = SummerFeatures()
        
        features.staticPivot = true
        features.staticTransform = true
        
        var settings = SummerSettings()
        
        settings.verticalAmp = -1
        
        do {
            engine = try SummerEngine(SummerMapTest(), view: summerView, features: features, settings: settings)
        } catch let e {
            switch e {
            case SummerError.cannotCreateDevice: print("Cannot create device!")
            case SummerError.noDefaultLibrary: print("No default library provided!")
            case SummerError.cannotCreateResources: print("Cannot create resources!")
            default: print("Too lazy to handle this error :/")
            }
        }
    }
}
