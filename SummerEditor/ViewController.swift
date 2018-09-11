//
//  ViewController.swift
//  SummerEditor
//
//  Created by Taylor Whatley on 2018-08-16.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Cocoa
import SummerEngine

class ViewController: NSViewController {
    @IBOutlet var summerView: SummerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let engine = try? SummerEngine(Editor(), view: summerView)
        
        if engine == nil { print("Could not start Summer Editor.") }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

