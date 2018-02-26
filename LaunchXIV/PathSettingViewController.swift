//
//  PathSettingViewController.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 17/7/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

protocol PathDragDropViewDelegate {
    func filePathDragged(url: URL) -> Bool
}

class PathDragDropView: NSView {
    var delegate: PathDragDropViewDelegate!
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if pathFrom(dragInfo: sender) != nil {
            sender.numberOfValidItemsForDrop = 1
            return .copy
        } else {
            return []
        }
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let url = pathFrom(dragInfo: sender) else {
            return false
        }
        return delegate.filePathDragged(url: url)
    }
    
    func pathFrom(dragInfo: NSDraggingInfo) -> URL? {
        let filenamesType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
        let pboard = dragInfo.draggingPasteboard()
        guard let files = pboard.propertyList(forType: filenamesType) as? [String] else {
            return nil
        }
        for file in files {
            let url = URL(fileURLWithPath: file)
            if appPathIsValid(url: url) {
                return url
            }
        }
        return nil
    }
}

fileprivate func appPathIsValid(url: URL?) -> Bool {
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

class PathSettingViewController: NSViewController, MainWindowContentViewController, PathDragDropViewDelegate {
    var navigator: Navigator!
    var settings: FFXIVSettings!
    
    @IBOutlet var imageView: NSImageView!
    @IBOutlet var topLabel: NSTextField!
    @IBOutlet var bottomLabel: NSTextField!
    @IBOutlet var dragDropView: PathDragDropView!
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // FFS APPLE WHAT THE ACTUAL
        let filenamesType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
        dragDropView.registerForDraggedTypes([filenamesType])
        dragDropView.delegate = self
        imageView.unregisterDraggedTypes()
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
                if appPathIsValid(url: url) {
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
            topLabel.stringValue = settings.appPath!.path
            let image = NSWorkspace.shared.icon(forFile: settings.appPath!.path)
            imageView.image = image
            imageView.imageFrameStyle = .grayBezel
        } else {
            // Render the placeholder
            topLabel.stringValue = "Choose Final Fantasy XIV.app to begin"
            imageView.imageFrameStyle = .none
            imageView.image = NSImage(named: NSImage.Name("DragSymbol"))
        }
    }
    
    func filePathDragged(url: URL) -> Bool {
        if appPathIsValid(url: url) {
            DispatchQueue.main.async {
                self.settings.appPath = url
                self.render()
            }
            return true
        }
        return false
    }
}
