//
//  LoginSettingsViewController.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 18/7/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Cocoa
import GNJSwitchControl

class LoginSettingsViewController: NSViewController, MainWindowContentViewController, NSTextFieldDelegate {
    var navigator: Navigator!
    var settings: FFXIVSettings!
    @IBOutlet var usernameField: NSTextField!
    @IBOutlet var passwordField: NSSecureTextField!
    @IBOutlet var otpSwitch: GNJSwitchControl!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        usernameField.stringValue = settings.credentials?.username ?? ""
        otpSwitch.state = settings.usesOneTimePassword
        
        usernameField.selectText(nil)
        usernameField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        proceed()
    }
    
    @IBAction func usernameAction(_ sender: Any) {
        proceed()
    }
    
    @IBAction func passwordAction(_ sender: Any) {
        proceed()
    }
    
    @IBAction func otpAction(_ sender: Any) {
        updateSettings()
    }
    
    func proceed() {
        if usernameField.stringValue.isEmpty {
            return
        }
        if passwordField.stringValue.isEmpty {
            return
        }
        updateSettings()
        if otpSwitch.state {
            navigator.goToOneTimePassword()
        } else {
            navigator.goToLoading()
        }
    }
    
    func updateSettings() {
        settings.credentials = FFXIVLoginCredentials(username: usernameField.stringValue, password: passwordField.stringValue)
        settings.usesOneTimePassword = otpSwitch.state
    }
    
}
