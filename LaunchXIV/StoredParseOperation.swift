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
        // TODO: rewrite this using JS
        guard let fields = webView.mainFrame.domDocument.getElementsByName("_STORED_") else {
            result = .error
            state = .finished
            return
        }
        for i in 0..<fields.length {
            let node = fields.item(i)!
            guard let inputNode = node as? DOMHTMLInputElement,
                let value = inputNode.value else {
                    continue
            }
            result = .result(value)
        }
        if result == nil {
            result = .error
        }
        state = .finished
    }
}
