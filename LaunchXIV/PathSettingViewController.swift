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
    
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var topLabel: NSTextField!
    @IBOutlet var bottomLabel: NSTextField!
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        render()
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        if appPathIsValid(url: settings.appPath) {
            navigator.goToLoginSettings()
        }
    }
    
    @IBAction func browseButtonAction(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.treatsFilePackagesAsDirectories = true
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = ["app", "APP"]
        panel.beginSheetModal(for: view.window!) { result in
            if result == .OK {
                guard let url = panel.urls.first else {
                    return
                }
                if self.appPathIsValid(url: url) {
                    self.settings.appPath = url
                } else {
                    // They (deliberately?) selected something wrong. Nil out.
                    self.settings.appPath = nil
                }
                self.render()
            }
        }
    }
    
    func render() {
        if appPathIsValid(url: settings.appPath) {
            // Render the icon and its path
            topLabel.isHidden = true
            bottomLabel.stringValue = settings.appPath!.path
            let image = NSWorkspace.shared.icon(forFile: settings.appPath!.path)
            imageView.image = image
            imageView.imageFrameStyle = .grayBezel
        } else {
            // Render the placeholder
            topLabel.isHidden = false
            bottomLabel.stringValue = "Drag your Final Fantasy XIV.app here or select it with Browse below"
            imageView.imageFrameStyle = .none
            imageView.image = NSImage(named: NSImage.Name("DragSymbol"))
        }
    }
    
    func appPathIsValid(url: URL?) -> Bool {
        guard let url = url else {
            return false
        }
        let fm = FileManager()
        if !url.isFileURL {
            return false
        }
        var isDir: ObjCBool = false
        if !fm.fileExists(atPath: url.path, isDirectory: &isDir) || !isDir.boolValue {
            return false
        }
        
        guard let bundle = Bundle(url: url) else {
            return false
        }
        guard let bundleId = bundle.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String) as? String else {
            return false
        }
        if bundleId != "com.transgaming.realmreborn" {
            return false
        }
        return true
    }
}
