//
//  StartGameOperation.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 28/2/18.
//  Copyright © 2018 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

class StartGameOperation: AsyncOperation {
    let settings: FFXIVSettings
    let sid: String
    
    init(settings: FFXIVSettings, sid: String) {
        self.settings = settings
        self.sid = sid
        super.init()
    }
    
    override func main() {
        guard let appURL = settings.appPath else {
            state = .finished
            return
        }
        let app = FFXIVApp(appURL)
        let args = arguments(app: app)
        let env = environment(app: app)
        try! NSWorkspace.shared.launchApplication(at: app.wineLoaderURL,
                                                  options: [],
                                                  configuration: [
                                                    .arguments: args,
                                                    .environment: env
        ])
        state = .finished
    }

    func environment(app: FFXIVApp) -> [String: String] {
        let userId = getuid()
        return [
            "CX_WINEWRAPPER_ALT_LOADER_SOCKET": "/var/tmp/tmp.1.AMHefm",
            "WINESERVER": "\(app.cxRoot.path)/bin/wineserver",
            "CX_BOTTLE": "published_Final_Fantasy",
            "CX_ROOT": app.cxRoot.path,
            "CX_MANAGED_BOTTLE_PATH": "\(app.appSupportRoot.path)/BuiltinBottles",
            "PATH": "\(app.cxRoot.path)/bin:/usr/bin:/bin:/usr/sbin:/sbin",
            "WINEPREFIX": app.bottleURL.path,
            "CX_APP_BUNDLE_PATH": app.appURL.path,
            "WINELOADER": "\(app.cxRoot.path)/bin/wineloader64",
            "CX_INITIALIZED": "\(userId):published_Final_Fantasy",
            "WINEDEBUG": "-all",
            "CX_BOTTLE_PATH": "\(app.appSupportRoot.path)/Bottles",
            "WINEDLLPATH": "",
            "CX_LAUNCH_NOTIFY_SOCKET": "/var/tmp/tmp.0.RAnlpo",
            "CX_DEBUGMSG": "-all",
            "WINELOADERNOEXEC": "1"
        ]
    }

    func arguments(app: FFXIVApp) -> [String] {
        let cmdline = [
            "language=1",
            "DEV.UseSqPack=1",
            "DEV.DataPathType=1",
            "DEV.LobbyHost01=neolobby01.ffxiv.com",
            "DEV.LobbyPort01=54994",
            "DEV.LobbyHost02=neolobby02.ffxiv.com",
            "DEV.LobbyPort02=54994",
            "DEV.TestSID=\(sid)",
            "DEV.MaxEntitledExpansionID=\(settings.expansionId.rawValue)",
            "SYS.Region=\(settings.region.rawValue)",
            "ver=\(app.gameVer)"
        ]
        return [
            "winewrapper.exe",
            "--enable-alt-loader",
            "macdrv",
            "--workdir",
            "C:/Program Files (x86)/SquareEnix/FINAL FANTASY XIV - A Realm Reborn/boot",
            "--run",
            "--",
            "../game/ffxiv_dx11.exe"
        ] + cmdline
    }
}
