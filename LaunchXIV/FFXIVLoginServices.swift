//
//  FFXIVLoginServices.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 13/3/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Foundation
import Security
import Locksmith
import Crypto


public enum FFXIVExpansionLevel: UInt32 {
    case aRealmReborn = 0
    case heavensward = 1
    case stormblood = 2 // Probably.
}

public enum FFXIVRegion: UInt32 {
    case japanese = 0
    case english = 1
    case french = 2
    case german = 3
    
    static func guessFromLocale() -> FFXIVRegion {
        switch NSLocale.current.languageCode {
        case "ja"?:
            return .japanese
        case "en"?:
            return .english
        case "fr"?:
            return .french
        case "de"?:
            return .german
        default:
            return .english
        }
    }
}

public struct FFXIVLoginData: InternetPasswordSecureStorable {
    let username: String
    let password: String
    var oneTimePassword: String? = nil
    
    public let authenticationType = LocksmithInternetAuthenticationType.htmlForm
    public let internetProtocol = LocksmithInternetProtocol.https
    public let port = 80
    public let server = "secure.square-enix.com"
    
    public init(username: String) {
        self.username = username
        password = ""
        oneTimePassword = nil
    }
    
    public init(username: String, password: String, oneTimePassword: String? = nil) {
        self.username = username
        self.password = password
        self.oneTimePassword = oneTimePassword
    }
    
    public var data: [String: Any] {
        return ["password": password]
    }
    
    public var account: String {
        return username
    }
    
    static func storedLogin(username: String) -> FFXIVLoginData? {
        let loginQuery = FFXIVLoginData(username: username)
        let keychainResult = loginQuery.readFromSecureStore()
        guard let passwordDict = keychainResult?.data else {
            return nil
        }
        guard let storedPassword = passwordDict["password"] as? String else {
            return nil
        }
        return FFXIVLoginData(username: username, password: storedPassword)
    }
    

}

extension FFXIVLoginData: ReadableSecureStorable {
    
}

extension FFXIVLoginData: DeleteableSecureStorable {
    
}

extension FFXIVLoginData: CreateableSecureStorable {
    
}

public enum FFXIVLoginResult {
    case success(sid: String)
    case clientUpdate
    case incorretCredentials
    case protocolError
}

private enum FFXIVLoginPageData {
    case success(storedSid: String)
    case error
}

public struct FFXIVSettings {
    public var login: FFXIVLoginData?
    public var expansionId: FFXIVExpansionLevel = .aRealmReborn
    public var directX11: Bool = false
    public var usesOneTimePassword: Bool = false
    public var appPath: URL = URL(fileURLWithPath: "/Applications/FINAL FANTASY XIV.app")
    public var region: FFXIVRegion = FFXIVRegion.guessFromLocale()
    
    static func storedSettings(storage: UserDefaults = UserDefaults.standard) -> FFXIVSettings {
        guard let storedUsername = storage.string(forKey: "username"),
            let login = FFXIVLoginData.storedLogin(username: storedUsername),
            let appPath = storage.string(forKey: "appPath"),
            let expansionId = FFXIVExpansionLevel(rawValue: UInt32(storage.integer(forKey: "expansionId"))),
            let region = FFXIVRegion(rawValue: UInt32(storage.integer(forKey: "region")))
        else {
            return FFXIVSettings()
        }
        
        let directX11 = storage.bool(forKey: "directX11")
        let usesOneTimePassword = storage.bool(forKey: "usesOneTimePassword")
        return FFXIVSettings(login: login, expansionId: expansionId, directX11: directX11,
                             usesOneTimePassword: usesOneTimePassword, appPath: URL(fileURLWithPath: appPath), region: region)
    }
    
    func serializeInto(storage: UserDefaults = UserDefaults.standard) {
        if let username = login?.username {
            storage.set(username, forKey: "username")
        }
        storage.set(expansionId.rawValue, forKey: "expansionId")
        storage.set(directX11, forKey: "directX11")
        storage.set(usesOneTimePassword, forKey: "usesOneTimePassword")
        storage.set(appPath, forKey: "appPath")
        storage.set(region, forKey: "region")
    }
}

private struct FFXIVLogin {
    static let userAgent = "SQEXAuthor/2.0.0(Windows XP; ja-jp; 3aed65f87c)"
    
    static let loginHeaders = [
        "User-Agent": userAgent
    ]
    
    static let authHeaders = [
        "User-Agent": userAgent,
        "Cookie": "",
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    static let versionHeaders = [
        "User-Agent": "FFXIV PATCH CLIENT"
    ]
    
    var loginURL: URL {
        return URL(string: "https://ffxiv-login.square-enix.com/oauth/ffxivarr/login/top?lng=en&rgn=\(settings.region)")!
    }
    
    let settings: FFXIVSettings
    let app: FFXIVApp
    
    init(settings: FFXIVSettings) {
        self.settings = settings
        app = FFXIVApp(settings.appPath)
    }
    
//    var bootVersion: String {
//        
//    }
//    
//    func login(completion: ((FFXIVLoginResult) -> Void)) {
//        
//    }
//    
//    func bootVersion() -> String {
//        
//    }
    
    private func getStoredSID(completion: @escaping ((FFXIVLoginPageData) -> Void)) {
        let session = URLSession(configuration: .default)
        let req = NSMutableURLRequest(url: loginURL)
        for (hdr, val) in FFXIVLogin.loginHeaders {
            req.addValue(val, forHTTPHeaderField: hdr)
        }
        let task = session.dataTask(with: req as URLRequest) { (data, resp, err) in
            guard let response = resp as? HTTPURLResponse else {
                completion(.error)
                return
            }
            guard let data = data else {
                completion(.error)
                return
            }
            if response.statusCode != 200 || err != nil || data.count == 0 {
                completion(.error)
                return
            }
            
            guard let html = String(data: data, encoding: .utf8) else {
                completion(.error)
                return
            }
            
            
        }
        task.resume()
    }
}

private struct FFXIVApp {
    let appURL: URL
    let bootExeURL: URL
    let launcherVersionURL: URL
    let launcherExeURL: URL
    let updaterExeURL: URL
    let ciderURL: URL
    let dx9URL: URL
    let dx11URL: URL
    let gameVersionURL: URL
    
    init(_ appURL: URL) {
        self.appURL = appURL
        let ffxiv = appURL
            .appendingPathComponent("Contents")
            .appendingPathComponent("Resources")
            .appendingPathComponent("transgaming")
            .appendingPathComponent("c_drive")
            .appendingPathComponent("ffxiv")
        
        let boot = ffxiv.appendingPathComponent("boot")
        bootExeURL = boot.appendingPathComponent("ffxivboot.exe")
        launcherVersionURL = boot.appendingPathComponent("ffxivgame.ver")
        launcherExeURL = boot.appendingPathComponent("ffxivlauncher.exe")
        updaterExeURL = boot.appendingPathComponent("ffxivupdater.exe")
        
        ciderURL = appURL
            .appendingPathComponent("Contents")
            .appendingPathComponent("MacOS")
            .appendingPathComponent("FINALFANTASYXIV")
        
        let game = appURL.appendingPathComponent("game")
        dx9URL = game.appendingPathComponent("ffxiv.exe")
        dx11URL = game.appendingPathComponent("ffxiv_dx11.exe")
        gameVersionURL = game.appendingPathComponent("ffxivgame.ver")
    }
    
    var bootVer: String {
        let data = try! Data.init(contentsOf: launcherVersionURL)
        return String(data: data, encoding: .utf8)!
    }
    
    var gameVer: String {
        let data = try! Data.init(contentsOf: gameVersionURL)
        return String(data: data, encoding: .utf8)!
    }
    
    var versionHash: String {
        let boot = FFXIVApp.sha1(file: bootExeURL)
        let launcher = FFXIVApp.sha1(file: launcherExeURL)
        let updater = FFXIVApp.sha1(file: updaterExeURL)
        
        return "\(boot),\(launcher),\(updater)"
    }
    
    private static func sha1(file: URL) -> String {
        let data = try! Data.init(contentsOf: file)
        var string = ""
        data.sha1.enumerateBytes { pointer, count, _ in
            for i in 0..<count {
                string += String(format: "%02x", pointer[i])
            }
        }
        return string
    }
}

