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
    
    @IBOutlet var loadingSpinner: NSProgressIndicator!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        loadingSpinner.startAnimation(self)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        doLogin()
    }
    
    func doLogin() {
        let queue = OperationQueue()
        let op = LoginOperation(settings: settings)
        op.completionBlock = {
            switch op.loginResult {
            case .success(let sid, let updatedSettings)?:
                self.settings = updatedSettings
                DispatchQueue.main.async {
                    self.startGame(sid: sid)
                }
            default:
                DispatchQueue.main.async {
                    self.settings.credentials!.deleteLogin()
                    self.navigator.goToLoginSettings()
                }
            }
        }
        queue.addOperation(op)
    }
    
    func startGame(sid: String) {
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
