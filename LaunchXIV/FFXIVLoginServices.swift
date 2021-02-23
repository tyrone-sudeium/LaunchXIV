//
//  FFXIVLoginServices.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 13/3/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Foundation
import Security
import KeychainAccess
import CommonCrypto


public enum FFXIVExpansionLevel: UInt32 {
    case aRealmReborn = 0
    case heavensward = 1
    case stormblood = 2
    case shadowbringers = 3
    case endwalker = 4
}

public enum FFXIVRegion: UInt32 {
    case japanese = 0
    case english = 3
    case french = 1
    case german = 2
    
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

public struct FFXIVServerLoginResponse {
    public let authOk: Bool
    public let sid: String?
    public let terms: UInt32?
    public let region: UInt32?
    public let etmAdd: UInt32? // ?? wat dis? maintenance maybe?
    public let playable: UInt32?
    public let ps3Package: UInt32?
    public let maxEx: UInt32?
    public let product: UInt32?
    
    public init?(string: String) {
        guard let loginVal = string.split(separator: "=").last else {
            return nil
        }
        let pairsArr = loginVal.split(separator: ",", maxSplits: Int.max, omittingEmptySubsequences: true)
        if pairsArr.count % 2 != 0 {
            return nil
        }
        var pairs = [String: String]()
        for i in stride(from: 0, to: pairsArr.count, by: 2) {
            pairs[String(pairsArr[i])] = String(pairsArr[i+1])
        }
        guard let auth = pairs["auth"] else {
            return nil
        }
        authOk = auth == "ok"
        sid = pairs["sid"]
        terms = pairs["terms"] != nil ? UInt32(pairs["terms"]!) : nil
        region = pairs["region"] != nil ? UInt32(pairs["region"]!) : nil
        etmAdd = pairs["etmadd"] != nil ? UInt32(pairs["etmadd"]!) : nil
        playable = pairs["playable"] != nil ? UInt32(pairs["playable"]!) : nil
        ps3Package = pairs["ps3pkg"] != nil ? UInt32(pairs["ps3pkg"]!) : nil
        maxEx = pairs["maxex"] != nil ? UInt32(pairs["maxex"]!) : nil
        product = pairs["product"] != nil ? UInt32(pairs["product"]!) : nil
    }
}

public struct FFXIVLoginCredentials {
    let username: String
    let password: String
    var oneTimePassword: String? = nil
    
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
    
    static func storedLogin(username: String) -> FFXIVLoginCredentials? {
        let keychain = Keychain(server: "https://secure.square-enix.com", protocolType: .https)
        // wtf Swift
        guard case let storedPassword?? = (((try? keychain.get(username)) as String??)) else {
            return nil
        }
        return FFXIVLoginCredentials(username: username, password: storedPassword)
    }
    
    static func deleteLogin(username: String) {
        let keychain = Keychain(server: "https://secure.square-enix.com", protocolType: .https)
        keychain[username] = nil
    }
    
    public func loginData(storedSID: String) -> Data {
        var cmp = URLComponents()
        let queryItems = [
            URLQueryItem(name: "_STORED_", value: storedSID),
            URLQueryItem(name: "sqexid", value: username),
            URLQueryItem(name: "password", value: password),
            URLQueryItem(name: "otppw", value: oneTimePassword ?? "")
        ]
        cmp.queryItems = queryItems
        let str = cmp.percentEncodedQuery!
        return str.data(using: .utf8)!
    }
    
    public func saveLogin() {
        let keychain = Keychain(server: "https://secure.square-enix.com", protocolType: .https)
        keychain[username] = password
    }
    
    public func deleteLogin() {
        FFXIVLoginCredentials.deleteLogin(username: username)
    }
}

public enum FFXIVLoginResult {
    case success(sid: String, updatedSettings: FFXIVSettings)
    case clientUpdate
    case incorrectCredentials
    case protocolError
    case networkError
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
        if bundleId != "com.square-enix.finalfantasyxiv" {
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
        if let creds = credentials {
            creds.saveLogin()
        }
    }
    
    public func login(completion: @escaping ((FFXIVLoginResult) -> Void)) {
        print(FFXIVApp(appPath!).versionHash)
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
    
    public mutating func update(from response: FFXIVServerLoginResponse) {
        if let rgnInt = response.region, let rgn = FFXIVRegion(rawValue: rgnInt) {
            region = rgn
        }
        if let expInt = response.maxEx, let expId = FFXIVExpansionLevel(rawValue: expInt) {
            expansionId = expId
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
    static let userAgent = "macSQEXAuthor/2.0.0(MacOSX; ja-jp)"
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
        return URL(string: "https://ffxiv-login.square-enix.com/oauth/ffxivarr/login/top?lng=en&rgn=\(settings.region.rawValue)&isft=0&issteam=0")!
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
            let cookie = response.allHeaderFields["Set-Cookie"] as? String
            let op = SidParseOperation(html: html)
            let queue = OperationQueue()
            op.completionBlock = {
                DispatchQueue.main.async {
                    guard case let .some(HTMLParseResult.result(result)) = op.result else {
                        completion(.protocolError)
                        return
                    }
                    guard let parsedResult = FFXIVServerLoginResponse(string: result) else {
                        completion(.protocolError)
                        return
                    }
                    if !parsedResult.authOk {
                        completion(.incorrectCredentials)
                        return
                    }
                    guard let sid = parsedResult.sid else {
                        completion(.protocolError)
                        return
                    }
                    var updatedSettings = self.settings
                    updatedSettings.update(from: parsedResult)
                    self.getFinalSID(tempSID: sid, cookie: cookie, updatedSettings: updatedSettings, completion: completion)
                }
            }
            queue.addOperation(op)
        }
    }
    
    fileprivate func getFinalSID(tempSID: String, cookie: String?, updatedSettings: FFXIVSettings, completion: @escaping ((FFXIVLoginResult) -> Void)) {
        var headers = FFXIVLogin.sessionHeaders
        if let cookie = cookie {
            headers["Cookie"] = cookie
        }
        headers["Referer"] = loginURL.absoluteString
        var url = sessionURL
        url = url.appendingPathComponent(tempSID)
        let postBody = app.versionHash.data(using: .utf8)
        fetch(headers: headers, url: url, postBody: postBody) { body, response in
            if let unexpectedResponseBody = body, unexpectedResponseBody.count > 0 {
                if (response.statusCode <= 299) {
                    completion(.clientUpdate)
                } else {
                    completion(.networkError)
                }
                return
            }
            guard let finalSid = response.allHeaderFields["X-Patch-Unique-Id"] as? String else {
                completion(.protocolError)
                return
            }
            completion(.success(sid: finalSid, updatedSettings: updatedSettings))
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

public struct FFXIVApp {
    let appURL: URL
    let bootExeURL: URL
    let bootExe64URL: URL
    let launcherVersionURL: URL
    let launcherExeURL: URL
    let launcherExe64URL: URL
    let updaterExeURL: URL
    let updaterExe64URL: URL
    let ciderURL: URL
    let dx9URL: URL
    let dx11URL: URL
    let gameVersionURL: URL
    
    init(_ appURL: URL) {
        self.appURL = appURL
        let bottle = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library")
            .appendingPathComponent("Application Support")
            .appendingPathComponent("FINAL FANTASY XIV ONLINE")
            .appendingPathComponent("Bottles")
            .appendingPathComponent("published_Final_Fantasy")

        let ffxiv = bottle
            .appendingPathComponent("drive_c")
            .appendingPathComponent("Program Files (x86)")
            .appendingPathComponent("SquareEnix")
            .appendingPathComponent("FINAL FANTASY XIV - A Realm Reborn")

        
        let boot = ffxiv.appendingPathComponent("boot")
        bootExeURL = boot.appendingPathComponent("ffxivboot.exe")
        bootExe64URL = boot.appendingPathComponent("ffxivboot64.exe")
        launcherVersionURL = boot.appendingPathComponent("ffxivgame.ver")
        launcherExeURL = boot.appendingPathComponent("ffxivlauncher.exe")
        launcherExe64URL = boot.appendingPathComponent("ffxivlauncher64.exe")
        updaterExeURL = boot.appendingPathComponent("ffxivupdater.exe")
        updaterExe64URL = boot.appendingPathComponent("ffxivupdater64.exe")

        ciderURL = appURL
            .appendingPathComponent("Contents")
            .appendingPathComponent("SharedSupport")
            .appendingPathComponent("finalfantasyxiv")
            .appendingPathComponent("bin")
            .appendingPathComponent("wine")
        
        let game = ffxiv.appendingPathComponent("game")
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
        let segments = [
            FFXIVApp.hashSegment(file: bootExeURL),
            FFXIVApp.hashSegment(file: bootExe64URL),
            FFXIVApp.hashSegment(file: launcherExeURL),
            FFXIVApp.hashSegment(file: launcherExe64URL),
            FFXIVApp.hashSegment(file: updaterExeURL),
            FFXIVApp.hashSegment(file: updaterExe64URL),
        ]
        return segments.joined(separator: ",")
    }
    
    private static func hashSegment(file: URL) -> String {
        let (hash, len) = FFXIVApp.sha1(file: file)
        return "\(file.lastPathComponent)/\(len)/\(hash)"
    }
    
    private static func sha1(file: URL) -> (String, Int) {
        let data = try! Data.init(contentsOf: file)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Void in
            CC_SHA1(bytes.baseAddress, UInt32(data.count), &hash)
        }

        var string = ""
        for byte in hash {
            string += String(format: "%02x", byte)
        }
        return (string, data.count)
    }
}
