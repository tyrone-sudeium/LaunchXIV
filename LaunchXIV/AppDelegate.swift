//
//  AppDelegate.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 13/3/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var pathSettingWindowController: PathSettingWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let c = PathSettingWindowController(windowNibName: NSNib.Name("PathSettingWindowController"))
        c.showWindow(nil)
        pathSettingWindowController = c
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

