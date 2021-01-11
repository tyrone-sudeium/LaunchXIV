//
//  StartGameOperation.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 28/2/18.
//  Copyright © 2018 Tyrone Trevorrow. All rights reserved.
//

import Cocoa

let checksumTable = [
    "f", "X", "1", "p", "G", "t", "d", "S",
    "5", "C", "A", "P", "4", "_", "V", "L"
]

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

    class func wineTickCount() -> UInt64 {
        // Simulates calling GetTickCount in Wine.
        let absTime = mach_absolute_time()
        return absTime / 1000000
    }

    class func wineTickCountContinuous() -> UInt64 {
        // Simulates calling GetTickCount in Wine.
        // Currently the version of Wine in FFXIV always uses mach_absolute_time
        // However, when Wine updates it might start using mach_continuous_time.
        // I've implemented both here but the continuous time version won't be used.
        var timebase: mach_timebase_info = mach_timebase_info()
        mach_timebase_info(&timebase)

        let ctime = mach_continuous_time()
        let numer = UInt64(timebase.numer)
        let denom = UInt64(timebase.denom)
        let monotonic_time = ctime * numer / denom / 100
        return monotonic_time / 10000
    }

    class func blowfishKey(ticks: UInt64) -> UInt64 {
        let maskedTicks = ticks & 0xFFFFFFFF
        let key = maskedTicks & 0xFFFF0000
        return key
    }

    class func doubleSpaceify(_ str: String) -> String {
        return str.replacingOccurrences(of: " ", with: "  ")
    }

    class func checksum(key: UInt64) -> String {
        let index = Int((key & 0x000F0000) >> 16)
        return checksumTable[index]
    }

    class func encryptedArgs(args: [(String, String)], ticks: UInt64) -> String {
        let key = blowfishKey(ticks: ticks)
        let check = checksum(key: key)
        let keyStr = String(format: "%08x", key)
        let keyBytes = [UInt8](keyStr.utf8)
        let str = args.reduce(into: "") { (result, tuple) in
            let (key, value) = tuple
            result += " \(doubleSpaceify(key)) =\(doubleSpaceify(value))"
        }
        let bytes = [UInt8](str.utf8)
        let blowfish = try! Blowfish(key: keyBytes)
        let cipherText = try! blowfish.encrypt(bytes)
        let b64 = Data(cipherText).base64EncodedString()
        let b64url = b64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")

        return "//**sqex0003\(b64url)\(check)**//"
    }
    
    func arguments(app: FFXIVApp) -> [String] {
        let ticks = StartGameOperation.wineTickCount()
        let args = [
            ("T", "\(ticks & 0xFFFFFFFF)"),
            ("/DEV.DataPathType", "1"),
            ("/DEV.MaxEntitledExpansionID", "\(settings.expansionId.rawValue)"),
            ("/DEV.TestSID", "\(sid)"),
            ("/DEV.UseSqPack", "1"),
            ("/SYS.Region", "\(settings.region.rawValue)"),
            ("/language", "1"),
            ("/ver", "\(app.gameVer)")
        ]
        let sqexRobotBarf = StartGameOperation.encryptedArgs(args: args, ticks: ticks)
        return [
            "winewrapper.exe",
            "--enable-alt-loader",
            "macdrv",
            "--workdir",
            "C:/Program Files (x86)/SquareEnix/FINAL FANTASY XIV - A Realm Reborn/boot",
            "--run",
            "--",
            "../game/ffxiv_dx11.exe",
            sqexRobotBarf
        ]
    }
}
