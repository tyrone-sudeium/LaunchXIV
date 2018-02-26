//
//  LoginSettingsViewController.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 18/7/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Cocoa
import OGSwitch

class LoginSettingsViewController: NSViewController, MainWindowContentViewController {
    var settings: FFXIVSettings!
    @IBOutlet var usernameField: NSTextField!
    @IBOutlet var passwordField: NSSecureTextField!
    @IBOutlet var otpSwitch: OGSwitch!
    
    
    @IBAction func nextButtonAction(_ sender: Any) {
        
    }
    
}
