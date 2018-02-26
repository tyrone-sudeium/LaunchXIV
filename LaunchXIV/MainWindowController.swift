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
    var view: NSView { get }
}

typealias ContentViewController = NSViewController & MainWindowContentViewController

class MainWindowController: NSWindowController, Navigator {
    @IBOutlet var contentView: NSView!
    var settings: FFXIVSettings!
    
    enum State {
        case pathSettings
        case loginSettings
        case oneTimePassword
        case loading
        
        private func loadViewController() -> ContentViewController {
            switch (self) {
            case .pathSettings:
                return PathSettingViewController(nibName: NSNib.Name("PathSettingViewController"), bundle: Bundle.main)
            case .loginSettings:
                return LoginSettingsViewController(nibName: NSNib.Name("LoginSettingsViewController"), bundle: Bundle.main)
            case .oneTimePassword:
                // TODO: crashy times
                return NSViewController() as! ContentViewController
            case .loading:
                return NSViewController() as! ContentViewController
            }
        }
        
        fileprivate func viewController(settings: FFXIVSettings) -> ContentViewController {
            var vc = loadViewController()
            vc.settings = settings
            return vc
        }
    }

    var state: State = .pathSettings
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        changeState(newState: state, animated: false)
    }
    
    func changeState(newState: State, animated: Bool) {
        state = newState
        let newVC = newState.viewController(settings: settings)
        if let oldVC = contentViewController {
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParentViewController()
        }
        contentView.addSubview(newVC.view)
        self.contentViewController = newVC
        
        var frame = window!.frame
        frame.size = newVC.view.bounds.size
        window!.setFrame(frame, display: true, animate: animated)
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
    
}
