//
//  AppDelegate.swift
//  SummerEngine
//
//  Created by Taylor Whatley on 2018-06-24.
//  Copyright © 2018 Taylor Whatley. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) { }
    func applicationWillTerminate(_ aNotification: Notification) { }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { return true }
}
