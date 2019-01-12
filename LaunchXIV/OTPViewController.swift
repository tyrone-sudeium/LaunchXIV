//
//  OTPViewController.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 11/1/19.
//  Copyright © 2019 Tyrone Trevorrow. All rights reserved.
//

import AppKit

class OTPViewController: NSViewController, MainWindowContentViewController, NSTextFieldDelegate {
    var navigator: Navigator!
    var settings: FFXIVSettings!
    @IBOutlet var otpField: NSTextField!
    
    @IBAction func textFieldReturnAction(_ sender: Any) {
        proceed()
    }
    
    func proceed() {
        if otpField.stringValue.isEmpty {
            return
        }
        settings.credentials?.oneTimePassword = otpField.stringValue
        navigator.goToLoading()
    }
}
