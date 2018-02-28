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
        var settings: FFXIVSettings
        if NSEvent.modifierFlags.contains(.option) {
            settings = FFXIVSettings()
        } else {
            settings = FFXIVSettings.storedSettings()
        }
        
        startApplication(settings: settings)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func startApplication(settings: FFXIVSettings) {
        mainWC = MainWindowController(windowNibName: NSNib.Name("MainWindowController"))
        mainWC?.settings = settings
        if mainWC?.initialState() == .loading {
            // All settings are good to go, attempt to autologin
            doLogin(settings: settings)
        } else {
            mainWC?.showWindow(self)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        mainWC?.saveSettings()
        return .terminateNow
    }
    
    func doLogin(settings: FFXIVSettings) {
        let queue = OperationQueue()
        let op = LoginOperation(settings: settings)
        op.completionBlock = {
            switch op.loginResult {
            case .success(let sid, let updatedSettings)?:
                DispatchQueue.main.async {
                    self.startGame(sid: sid, settings: updatedSettings)
                }
            default:
                DispatchQueue.main.async {
                    var updatedSettings = settings
                    updatedSettings.credentials = nil
                    self.mainWC?.settings = updatedSettings
                    self.mainWC?.showWindow(self)
                }
            }
        }
        queue.addOperation(op)
    }
    
    func startGame(sid: String, settings: FFXIVSettings) {
        let queue = OperationQueue()
        let op = StartGameOperation(settings: settings, sid: sid)
        op.completionBlock = {
            DispatchQueue.main.async {
                NSApp.terminate(nil)
            }
        }
        queue.addOperation(op)
    }
}

