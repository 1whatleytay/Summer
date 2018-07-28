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
        
        engine = try? SummerEngine(SummerMapTest(), view: summerView)
        
        if engine == nil { print("Failed to start SummerEngine.") }
    }
}
