//
//  PathSettingWindowController.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 17/7/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

class PathSettingWindowController: NSWindowController {
    var navigator: ApplicationNavigation?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.backgroundColor = NSColor.white
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        window?.close()
        navigator?.showLoginSettingsWindow()
    }
}
