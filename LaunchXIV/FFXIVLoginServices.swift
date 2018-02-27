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
    case stormblood = 2
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

public struct FFXIVLoginCredentials: InternetPasswordSecureStorable {
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
    
    static func storedLogin(username: String) -> FFXIVLoginCredentials? {
        let loginQuery = FFXIVLoginCredentials(username: username)
        let keychainResult = loginQuery.readFromSecureStore()
        guard let passwordDict = keychainResult?.data else {
            return nil
        }
        guard let storedPassword = passwordDict["password"] as? String else {
            return nil
        }
        return FFXIVLoginCredentials(username: username, password: storedPassword)
    }
    
    public func loginData(storedSID: String) -> Data {
        var cmp = URLComponents()
        var queryItems = [
            URLQueryItem(name: "_STORED_", value: storedSID),
            URLQueryItem(name: "sqexid", value: username),
            URLQueryItem(name: "password", value: password)
        ]
        if let otp = oneTimePassword {
            queryItems.append(URLQueryItem(name: "otppw", value: otp))
        }
        cmp.queryItems = queryItems
        let str = cmp.percentEncodedQuery!
        return str.data(using: .utf8)!
    }
}

extension FFXIVLoginCredentials: ReadableSecureStorable {
    
}

extension FFXIVLoginCredentials: DeleteableSecureStorable {
    
}

extension FFXIVLoginCredentials: CreateableSecureStorable {
    
}

public enum FFXIVLoginResult {
    case success(sid: String)
    case clientUpdate
    case incorrectCredentials
    case protocolError
}

private enum FFXIVLoginPageData {
    case success(storedSid: String, cookie: String?)
    case error
}

public struct FFXIVSettings {
    public var credentials: FFXIVLoginCredentials?
    public var expansionId: FFXIVExpansionLevel = .aRealmReborn
    public var directX11: Bool = false
    public var usesOneTimePassword: Bool = false
    public var appPath: URL?
    public var region: FFXIVRegion = FFXIVRegion.guessFromLocale()
    
    static func storedSettings(storage: UserDefaults = UserDefaults.standard) -> FFXIVSettings {
        var settings = FFXIVSettings()
        if let storedUsername = storage.string(forKey: "username") {
            let login = FFXIVLoginCredentials.storedLogin(username: storedUsername)
            settings.credentials = login
        }
        if let path = storage.string(forKey: "appPath") {
            settings.appPath = URL(fileURLWithPath: path)
        }
        if let expansionId = FFXIVExpansionLevel(rawValue: UInt32(storage.integer(forKey: "expansionId"))) {
            settings.expansionId = expansionId
        }
        if let region = FFXIVRegion(rawValue: UInt32(storage.integer(forKey: "region"))) {
            settings.region = region
        }
        settings.directX11 = storage.bool(forKey: "directX11")
        settings.usesOneTimePassword = storage.bool(forKey: "usesOneTimePassword")
        return settings
    }
    
    static func appPathIsValid(url: URL?) -> Bool {
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
    
    func serialize(into storage: UserDefaults = UserDefaults.standard) {
        if let username = credentials?.username {
            storage.set(username, forKey: "username")
        }
        storage.set(expansionId.rawValue, forKey: "expansionId")
        storage.set(directX11, forKey: "directX11")
        storage.set(usesOneTimePassword, forKey: "usesOneTimePassword")
        storage.set(appPath?.path, forKey: "appPath")
        storage.set(region.rawValue, forKey: "region")
        storage.synchronize()
    }
    
    public func login(completion: @escaping ((FFXIVLoginResult) -> Void)) {
        if credentials == nil {
            completion(.incorrectCredentials)
            return
        }
        guard let login = FFXIVLogin(settings: self) else {
            return
        }
        login.getStored() { result in
            switch result {
            case .error:
                completion(.protocolError)
            case .success(let storedSid, let cookie):
                login.getTempSID(storedSID: storedSid, cookie: cookie, completion: completion)
            }
        }
    }
}

private class FFXIVSSLDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // Always trust the Square Enix server. Yep, this can totally make us vulnerable to MITM, but you can
        // blame SE for not setting up SSL correctly! The REAL launcher is vulnerable to MITM.
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

private struct FFXIVLogin {
    static let userAgent = "SQEXAuthor/2.0.0(Windows XP; ja-jp; 3aed65f87c)"
    static let authURL = URL(string: "https://ffxiv-login.square-enix.com/oauth/ffxivarr/login/login.send")!
    
    static let loginHeaders = [
        "User-Agent": userAgent
    ]
    
    static let authHeaders = [
        "User-Agent": userAgent,
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    static let sessionHeaders = [
        "User-Agent": userAgent,
        "Content-Type": "application/x-www-form-urlencoded",
        "X-Hash-Check": "enabled"
    ]
    
    
    static let versionHeaders = [
        "User-Agent": "FFXIV PATCH CLIENT"
    ]
    
    var loginURL: URL {
        return URL(string: "https://ffxiv-login.square-enix.com/oauth/ffxivarr/login/top?lng=en&rgn=\(settings.region)")!
    }
    
    var sessionURL: URL {
        return URL(string: "https://patch-gamever.ffxiv.com/http/win32/ffxivneo_release_game/\(app.gameVer)")!
    }
    
    let settings: FFXIVSettings
    let app: FFXIVApp
    let sslDelegate = FFXIVSSLDelegate()
    
    init?(settings: FFXIVSettings) {
        guard let url = settings.appPath else {
            return nil
        }
        self.settings = settings
        app = FFXIVApp(url)
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
    
    fileprivate func getStored(completion: @escaping ((FFXIVLoginPageData) -> Void)) {
        fetch(headers: FFXIVLogin.loginHeaders, url: loginURL, postBody: nil) { body, response in
            guard let html = body else {
                completion(.error)
                return
            }
            let cookie = response.allHeaderFields["Set-Cookie"] as? String
            let op = StoredParseOperation(html: html)
            let queue = OperationQueue()
            op.completionBlock = {
                DispatchQueue.main.async {
                    guard case let .some(HTMLParseResult.result(result)) = op.result else {
                        completion(.error)
                        return
                    }
                    completion(.success(storedSid: result, cookie: cookie))
                }
            }
            queue.addOperation(op)
        }
    }
    
    fileprivate func getTempSID(storedSID: String, cookie: String?, completion: @escaping ((FFXIVLoginResult) -> Void)) {
        var headers = FFXIVLogin.authHeaders
        if let cookie = cookie {
            headers["Cookie"] = cookie
        }
        headers["Referer"] = loginURL.absoluteString
        let postBody = settings.credentials!.loginData(storedSID: storedSID)
        fetch(headers: headers, url: FFXIVLogin.authURL, postBody: postBody) { body, response in
            guard let html = body else {
                completion(.protocolError)
                return
            }
            print("got temp sid data:\n\(html)")
        }
    }
    
    fileprivate func getFinalSID(tempSID: String, cookie: String?, completion: @escaping ((FFXIVLoginResult) -> Void)) {
        var headers = FFXIVLogin.sessionHeaders
        if let cookie = cookie {
            headers["Cookie"] = cookie
        }
        headers["Referer"] = loginURL.absoluteString
        var url = sessionURL
        url = url.appendingPathComponent(tempSID)
        let postBody = app.versionHash.data(using: .utf8)
        fetch(headers: headers, url: url, postBody: postBody) { body, response in
            guard let html = body else {
                completion(.protocolError)
                return
            }
            print("got final sid data:\n\(html)")
            guard let finalSid = response.allHeaderFields["X-Patch-Unique-Id"] else {
                completion(.protocolError)
                return
            }
            print("got final sid:\n\(finalSid)")
        }
    }
    
    fileprivate func fetch(headers: [String: String], url: URL, postBody: Data?, completion: @escaping ((_ body: String?, _ response: HTTPURLResponse) -> Void)) {
        let session = URLSession(configuration: .default, delegate: sslDelegate, delegateQueue: nil)
        let req = NSMutableURLRequest(url: url)
        for (hdr, val) in headers {
            req.addValue(val, forHTTPHeaderField: hdr)
        }
        if let uploadedBody = postBody {
            req.httpBody = uploadedBody
            req.httpMethod = "POST"
        }
        let task = session.dataTask(with: req as URLRequest) { (data, resp, err) in
            let response = resp as! HTTPURLResponse
            guard let data = data else {
                completion(nil, response)
                return
            }
            if response.statusCode != 200 || err != nil || data.count == 0 {
                completion(nil, response)
                return
            }
            
            guard let html = String(data: data, encoding: .utf8) else {
                completion(nil, response)
                return
            }
            completion(html, response)
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
        
        return "ffxivboot.exe/\(boot),ffxivlauncher.exe/\(launcher),ffxivupdater.exe/\(updater)"
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

