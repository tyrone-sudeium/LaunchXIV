//
//  StoredParseOperation.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 19/7/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import WebKit

public class StoredParseOperation: HTMLParseOperation {
    public override func parseWebView() {
        webView.evaluateJavaScript("document.querySelectorAll('input[name=\"_STORED_\"]')[0].value") { object, error in
            if error != nil {
                self.result = .error
                self.state = .finished
                return
            }
            guard let jsStr = object as? String else {
                self.result = .error
                self.state = .finished
                return
            }
            self.result = .result(jsStr)
            self.state = .finished
        }
    }
}
