//
//  LoadingViewController.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 27/2/18.
//  Copyright © 2018 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

class LoadingViewController: NSViewController, MainWindowContentViewController {
    var navigator: Navigator!
    var settings: FFXIVSettings!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        doLogin()
    }
    
    func doLogin() {
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
}
