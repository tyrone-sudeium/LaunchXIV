//
//  AppDelegate.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 13/3/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

protocol ApplicationNavigation {
    func showPathSettingWindow()
    func showLoginSettingsWindow()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ApplicationNavigation {
    
    var pathWC: PathSettingWindowController?
    var loginWC: LoginSettingsWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        showPathSettingWindow()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
    func showPathSettingWindow() {
        pathWC = PathSettingWindowController(windowNibName: NSNib.Name("PathSettingWindowController"))
        pathWC?.showWindow(nil)
        pathWC?.navigator = self
    }
    
    func showLoginSettingsWindow() {
        loginWC = LoginSettingsWindowController(windowNibName: NSNib.Name("LoginSettingsWindowController"))
        loginWC?.showWindow(nil)
        loginWC?.navigator = self
    }
}

