//
//  SidParseOperation.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 27/2/18.
//  Copyright © 2018 Tyrone Trevorrow. All rights reserved.
//

import Cocoa
import WebKit
import JavaScriptCore

@objc protocol SidParseJSExport: JSExport {
    func user(_ string: String)
}

@objc public class SidParseOperation: HTMLParseOperation, SidParseJSExport {
    var loginStr: String?
    
    public override func parseWebView() {
        guard let jsText = webView.mainFrame.domDocument.getElementsByName("mainForm")?.item(0)?.childNodes?.item(1)?.textContent else {
            errorOut()
            return
        }
        let js = JSContext()!
        js.exceptionHandler = { context, value in
            print(value!.debugDescription)
        }
        let window = JSValue(newObjectIn: js)!
        window.setObject(self, forKeyedSubscript: "external" as NSString)
        js.setObject(window, forKeyedSubscript: "window" as NSString)

        // This should hopefully cause the user function to get called
        js.evaluateScript(jsText)
        
        guard let str = loginStr else {
            errorOut()
            return
        }
        result = .result(str)
        state = .finished
    }
    
    func errorOut() {
        result = .error
        state = .finished
        return
    }
    
    @objc func user(_ string: String) {
        loginStr = string
    }
}
