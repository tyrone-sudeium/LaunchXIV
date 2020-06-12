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
        try! Process.run(app.ciderURL, arguments: args)
        state = .finished
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
