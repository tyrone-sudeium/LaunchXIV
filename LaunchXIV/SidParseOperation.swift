//
//  StoredSidParser.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 19/7/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Foundation
import WebKit

// Fetches the stored sid out of a login page html
public enum SidParseResult: Equatable {
    case result(String)
    case error
    
    public static func ==(lhs: SidParseResult, rhs: SidParseResult) -> Bool {
        switch (lhs, rhs) {
        case (.error, .error):
            return true
        case (let .result(r1), let .result(r2)):
            return r1 == r2
        default:
            return false
        }
    }
}

class SidParseOperation: Operation, WebFrameLoadDelegate {
    let html: String
    
    init(html: String) {
        self.html = html
        super.init()
    }
    
    enum State: String {
        case ready, executing, finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: "isExecuting")
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    var webView: WebView!
    var result: SidParseResult?
    
    override func main() {
        if self.isCancelled {
            state = .finished
            return
        } else {
            state = .executing
        }
        
        DispatchQueue.main.async {
            self.webView = WebView()
            self.webView.frameLoadDelegate = self
            self.webView.mainFrame.loadHTMLString(self.html, baseURL: URL(string: "http://localhost"))
        }
    }
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        guard let fields = webView.mainFrame.domDocument.getElementsByName("_STORED_") else {
            result = .error
            state = .finished
            return
        }
        for i in 0..<fields.length {
            let node = fields.item(i)!
            guard let inputNode = node as? DOMHTMLInputElement,
                let value = inputNode.value else {
                result = .error
                state = .finished
                return
            }
            result = .result(value)
            state = .finished
        }
    }
}
