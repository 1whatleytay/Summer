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
//    override public func keyUp(with event: NSEvent) {
//        print("Oh Up")
//    }
//    
//    override public func keyDown(with event: NSEvent) {
//        print("Oh Down")
//    }
//    
//    override public func performKeyEquivalent(with event: NSEvent) -> Bool {
//        return true
//    }
    
    @IBOutlet var summerView: SummerView!
    
    var engine: SummerEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            engine = try SummerEngine(SummerGame(), view: summerView)
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

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
