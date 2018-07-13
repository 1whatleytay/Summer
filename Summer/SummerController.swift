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
        
        do {
            engine = try SummerEngine(SummerMapTest(), view: summerView, features: features)
        } catch let e {
            switch e {
            case SummerError.cannotCreateDevice: print("Cannot create device!")
            case SummerError.cannotCreateQueue: print("Cannot create queue!")
            case SummerError.noDefaultLibrary: print("No default library provided!")
            case SummerError.cannotCreatePipelineState: print("Cannot create pipeline state!")
            default: print("Too lazy to handle this error :/")
            }
        }
    }
}
