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
        
        fileprivate func viewController(settings: FFXIVSettings, navigator: Navigator) -> ContentViewController {
            var vc = loadViewController()
            vc.settings = settings
            vc.navigator = navigator
            return vc
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
        if settings.credentials == nil {
            return .loginSettings
        }
        if settings.usesOneTimePassword {
            return .oneTimePassword
        }
        return .loading
    }

    func changeState(newState: State, animated: Bool) {
        state = newState
        if let oldVC = contentVC {
            // Pull the settings out of the old and pass to the new
            settings = oldVC.settings
            
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParentViewController()
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
    
}
