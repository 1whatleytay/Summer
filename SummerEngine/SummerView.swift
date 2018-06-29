//
//  SummerView.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-24.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import MetalKit

public class SummerView: MTKView {
    private var engine: SummerEngine!
    
    override public func keyDown(with event: NSEvent) {
        print("Key Down!")
    }
    
    override public func keyUp(with event: NSEvent) {
        print("Key Up!")
    }
    
    override public func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    internal func subscribeToEvents() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) {
            self.keyUp(with: $0)
            return $0
        }
    }
    
    internal func setEngine(engine: SummerEngine) -> Bool {
        if self.engine == nil {
            self.engine = engine
            self.delegate = engine
            self.subscribeToEvents()
            return true
        } else {
            return false
        }
    }
}
