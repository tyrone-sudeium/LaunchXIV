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

public class SidParseOperation: AsyncOperation, WebFrameLoadDelegate {
    let html: String
    
    init(html: String) {
        self.html = html
        super.init()
    }
    
    var webView: WebView!
    var result: SidParseResult?
    
    override open func main() {
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
    
    public func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
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
