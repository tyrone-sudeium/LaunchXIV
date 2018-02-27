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
    var mainWC: MainWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let settings = FFXIVSettings.storedSettings()
        showMainWindow(settings: settings)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func showMainWindow(settings: FFXIVSettings) {
        mainWC = MainWindowController(windowNibName: NSNib.Name("MainWindowController"))
        mainWC?.settings = settings
        mainWC?.showWindow(self)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        mainWC?.settings.serialize()
        return .terminateNow
    }
}

