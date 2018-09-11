//
//  SummerView.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-24.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import MetalKit

/// Allows for input control over a view.
public class SummerView: MTKView {
    private var engine: SummerEngine?
    
    override public func keyDown(with event: NSEvent) {
        if let parent = engine {
            parent.keyChanged(key: event.keyCode, characters: event.characters, state: .pressed)
        }
    }
    
    override public func keyUp(with event: NSEvent) {
        if let parent = engine {
            parent.keyChanged(key: event.keyCode, characters: event.characters, state: .released)
        }
    }
    
    override public func mouseUp(with event: NSEvent) {
        if let parent = engine {
            let point = event.locationInWindow
            parent.mouseButtonChanged(button: .left,
                                      x: Double(point.x), y: Double(point.y),
                                      state: .released)
        }
    }
    
    override public func mouseDown(with event: NSEvent) {
        if let parent = engine {
            let point = event.locationInWindow
            parent.mouseButtonChanged(button: .left,
                                      x: Double(point.x), y: Double(point.y),
                                      state: .pressed)
        }
    }
    
    override public func rightMouseUp(with event: NSEvent) {
        if let parent = engine {
            let point = event.locationInWindow
            parent.mouseButtonChanged(button: .right,
                                      x: Double(point.x), y: Double(point.y),
                                      state: .released)
        }
    }
    
    override public func rightMouseDown(with event: NSEvent) {
        if let parent = engine {
            let point = event.locationInWindow
            parent.mouseButtonChanged(button: .right,
                                      x: Double(point.x), y: Double(point.y),
                                      state: .pressed)
        }
    }
    
    override public func otherMouseUp(with event: NSEvent) {
        if let parent = engine {
            let point = event.locationInWindow
            parent.mouseButtonChanged(button: .other,
                                      x: Double(point.x), y: Double(point.y),
                                      state: .released)
        }
    }
    
    override public func otherMouseDown(with event: NSEvent) {
        if let parent = engine {
            let point = event.locationInWindow
            parent.mouseButtonChanged(button: .other,
                                      x: Double(point.x), y: Double(point.y),
                                      state: .pressed)
        }
    }
    
    override public func mouseMoved(with event: NSEvent) {
        if let parent = engine {
            let point = event.locationInWindow
            parent.mouseMoved(x: Double(point.x), y: Double(point.y))
        }
    }
    
    override public func performKeyEquivalent(with event: NSEvent) -> Bool {
        return true
    }
    
    internal func subscribeToEvents() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { self.keyDown(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) { self.keyUp(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { self.mouseUp(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { self.mouseDown(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .rightMouseUp) { self.rightMouseUp(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { self.rightMouseDown(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .otherMouseUp) { self.otherMouseUp(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .otherMouseDown) { self.otherMouseDown(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { self.mouseMoved(with: $0); return $0 }
        
        // Dragged event?
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDragged) { self.mouseMoved(with: $0); return $0 }
        NSEvent.addLocalMonitorForEvents(matching: .rightMouseDragged) { self.mouseMoved(with: $0); return $0 }
    }
    
    internal func setEngine(engine: SummerEngine) -> Bool {
        if self.engine == nil {
            self.engine = engine
            self.delegate = engine
            if engine.features.subscribeToEvents { self.subscribeToEvents() }
            return true
        } else {
            return false
        }
    }
}
