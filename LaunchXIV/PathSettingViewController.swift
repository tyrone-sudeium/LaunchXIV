//
//  PathSettingViewController.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 17/7/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

class PathSettingViewController: NSViewController, MainWindowContentViewController {
    var navigator: Navigator!
    var settings: FFXIVSettings!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        render()
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if appPathIsValid() {
            navigator.goToLoginSettings()
        }
    }
    
    func render() {
        if appPathIsValid() {
            // Render the icon and its path
        } else {
            // Render the placeholder
        }
    }
    
    func appPathIsValid() -> Bool {
        let fm = FileManager()
        let url = settings.appPath
        if !url.isFileURL {
            return false
        }
        var isDir: ObjCBool = false
        if !fm.fileExists(atPath: url.path, isDirectory: &isDir) || !isDir.boolValue {
            return false
        }
        return true
    }
}
