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
        
        return;
        // TODO: The below happens after username/password/otp

        settings.login() { result in
            switch result {
            case .protocolError:
                let alert = NSAlert()
                alert.addButton(withTitle: "Ok")
                alert.alertStyle = .critical
                alert.messageText = "Login system error"
                alert.informativeText = "The login servers did not present the login challenge the way we were expecting. " +
                    "It may have changed on the server. Please check for an update to LaunchXIV to fix this. In the meantime " +
                    "please use the default launcher."
                alert.runModal()
                exit(0)
            case .incorrectCredentials:
                break
            case .clientUpdate:
                let alert = NSAlert()
                alert.addButton(withTitle: "Ok")
                alert.alertStyle = .critical
                alert.messageText = "Final Fantasy XIV Needs Updating!"
                alert.informativeText = "LaunchXIV cannot patch Final Fantasy XIV. Please use the standard launcher to patch."
                alert.runModal()
                exit(0)
            case .success(let sid):
                print("sid = \(sid)")
            }
        }
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
}

