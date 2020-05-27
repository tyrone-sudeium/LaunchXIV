//
//  MainWindowController.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 26/2/18.
//  Copyright © 2018 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

protocol Navigator {
    func goToPathSettings()
    func goToLoginSettings()
    func goToOneTimePassword()
    func goToLoading()
}

protocol MainWindowContentViewController {
    var settings: FFXIVSettings! { get set }
    var navigator: Navigator! { get set }
}

typealias ContentViewController = NSViewController & MainWindowContentViewController

class MainWindowController: NSWindowController, Navigator {
    @IBOutlet var contentView: NSView!
    @IBOutlet var toolbar: NSToolbar!
    @IBOutlet var backToolbarItem: NSToolbarItem!
    var settings: FFXIVSettings!
    
    enum State: Int {
        case pathSettings
        case loginSettings
        case oneTimePassword
        case loading
        
        private func loadViewController() -> ContentViewController {
            switch (self) {
            case .pathSettings:
                return PathSettingViewController(nibName: "PathSettingViewController", bundle: Bundle.main)
            case .loginSettings:
                return LoginSettingsViewController(nibName: "LoginSettingsViewController", bundle: Bundle.main)
            case .oneTimePassword:
                return OTPViewController(nibName: "OTPViewController", bundle: Bundle.main)
            case .loading:
                return LoadingViewController(nibName: "LoadingViewController", bundle: Bundle.main)
            }
        }
        
        fileprivate func viewController(settings: FFXIVSettings, navigator: Navigator) -> ContentViewController {
            var vc = loadViewController()
            vc.settings = settings
            vc.navigator = navigator
            return vc
        }
        
        func next() -> State? {
            if let next = State(rawValue: self.rawValue + 1) {
                return next
            }
            return nil
        }
        
        func previous() -> State? {
            if let prev = State(rawValue: self.rawValue - 1) {
                return prev
            }
            return nil
        }
    }

    var state: State = .pathSettings
    
    // It's like NSWindowController's contentViewController, but without the weird-ass behaviour
    // specifically: it lets me change the current view and animate the size change
    var contentVC: ContentViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.changeState(newState: self.initialState(), animated: false)
        }
    }
    
    func initialState() -> State {
        if settings.appPath == nil {
            return .pathSettings
        }
        guard let credentials = settings.credentials else {
            return .loginSettings
        }
        if credentials.username.count == 0 || credentials.password.count == 0 {
            return .loginSettings
        }
        if settings.usesOneTimePassword {
            return .oneTimePassword
        }
        return .loading
    }

    func changeState(newState: State, animated: Bool) {
        state = newState
        
        backToolbarItem.isEnabled = state != .pathSettings
        
        if let oldVC = contentVC {
            // Pull the settings out of the old and pass to the new
            settings = oldVC.settings
            
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
        }
        
        let newVC = newState.viewController(settings: settings, navigator: self)
        
        var frame = window!.frame
        frame.size = newVC.view.bounds.size
        frame.size.height += 20
        window!.setFrame(frame, display: true, animate: animated)
        window!.contentMinSize = newVC.view.bounds.size
        
        contentView.addSubview(newVC.view)
        contentVC = newVC
    }
    
    func goToPathSettings() {
        changeState(newState: .pathSettings, animated: true)
    }
    
    func goToLoginSettings() {
        changeState(newState: .loginSettings, animated: true)
    }
    
    func goToOneTimePassword() {
        changeState(newState: .oneTimePassword, animated: true)
    }
    
    func goToLoading() {
        changeState(newState: .loading, animated: true)
    }

    @IBAction func goBack(_ sender: Any) {
        if let newState = state.previous() {
            changeState(newState: newState, animated: true)
        }
    }

    func saveSettings() {
        // Retrieve latest settings from the current screen
        if let settings = contentVC?.settings {
            settings.serialize()
        }
    }
    
}
