//
//  AsyncOperation.swift
//  LaunchXIV
//
//  Created by Tyrone Trevorrow on 19/7/17.
//  Copyright © 2017 Tyrone Trevorrow. All rights reserved.
//

import Foundation

open class AsyncOperation: Operation {
    public enum State: String {
        case ready, executing, finished
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    public var state = State.ready {
        willSet {
            willChangeValue(forKey: "isExecuting")
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override open var isExecuting: Bool {
        return state == .executing
    }
    
    override open var isFinished: Bool {
        return state == .finished
    }
    
    override open func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    override open func main() {
        // override in subclasses
    }
}
