//  https://github.com/GenjiApp/GNJSwitchControl
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Genji
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//  GNJSwitchControl.swift
//  GNJSwitchControl
//
//  Created by Genji on 2015/10/14.
//  Copyright © 2015 Genji App. All rights reserved.
//

import Cocoa

//////////////////
// MARK: Constants
private let kOffStateBackgroundColor = NSColor(white: 0.4, alpha: 1.0)
private let kBackgroundBorderColor = NSColor(white: 0.4, alpha: 0.5)
private let kKnobBorderColor = NSColor(white: 0.7, alpha: 1.0)
private let kKnobColor = NSColor(white: 0.9, alpha: 1.0)
private let kClickedKnobColor = NSColor(white: 0.85, alpha: 1.0)
private let kCornerRadiusRatio: CGFloat = 0.25
private let kDraggingEdgeMargin: CGFloat = 10.0

@IBDesignable
public class GNJSwitchControl: NSControl, CALayerDelegate {
    
    /////////////////////
    // MARK: - Properties
    @IBInspectable public var tintColor: NSColor = NSColor.green {
        didSet {
            if state {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                backgroundLayer.backgroundColor = tintColor.cgColor
                CATransaction.commit()
            }
        }
    }
    
    @IBInspectable public var state: Bool = false {
        didSet {
            knobLayer.frame.origin.x = state ? NSMaxX(bounds) - NSWidth(knobLayer.frame) : 0.0
            backgroundLayer.backgroundColor = state ? tintColor.cgColor : kOffStateBackgroundColor.cgColor
        }
    }
    
    @IBInspectable public override var isEnabled: Bool {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            // layer?.opacity = 0.5, if knobGradientLayer is visible
            // The background of the rounded corner of knobLayer can not be zero
            // or it will distort.
            knobGradientLayer.opacity = isEnabled ? 1.0 : 0.0
            layer?.opacity = isEnabled ? 1.0 : 0.5
            CATransaction.commit()
        }
    }
    
    // It seems like you should be able to override isHighlighted, but it
    // doesn't work. If you set isHighlighted to true, and then print()
    // in mouseDragged(), it will immediately return false.
    private var activated: Bool = false {
        didSet {
            knobLayer.backgroundColor = activated ? kClickedKnobColor.cgColor : kKnobColor.cgColor
        }
    }
    
    private var clickedLocationInKnob: CGPoint? = nil
    private var dragged = false
    
    private let backgroundLayer = CALayer()
    private let backgroundGradientLayer = CAGradientLayer()
    private let knobLayer = CALayer()
    private let knobGradientLayer = CAGradientLayer()
    
    
    ///////////////////////
    // MARK: - Initializers
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    /////////////////////////
    // MARK: - Private Method
    private func setup() {
        isEnabled = true
        wantsLayer = true
        let rootLayer = CALayer()
        rootLayer.needsDisplayOnBoundsChange = true
        rootLayer.delegate = self
        layer = rootLayer
        
        backgroundLayer.masksToBounds = true
        backgroundLayer.borderColor = kBackgroundBorderColor.cgColor
        backgroundLayer.borderWidth = 1.0
        backgroundLayer.backgroundColor = kOffStateBackgroundColor.cgColor
        layer?.addSublayer(backgroundLayer)
        
        backgroundGradientLayer.colors = [
            NSColor(white: 0.5, alpha: 0.0).cgColor,
            NSColor(white: 0.5, alpha: 0.25).cgColor,
        ]
        backgroundGradientLayer.locations = [
            0.0, 0.95
        ]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        backgroundGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        backgroundLayer.addSublayer(backgroundGradientLayer)
        
        knobLayer.masksToBounds = true
        knobLayer.borderColor = kKnobBorderColor.cgColor
        knobLayer.borderWidth = 1.0
        knobLayer.backgroundColor = kKnobColor.cgColor
        layer?.addSublayer(knobLayer)
        
        knobGradientLayer.colors = [
            NSColor(white: 1.0, alpha: 0.2).cgColor,
            NSColor(white: 1.0, alpha: 0.3).cgColor,
            NSColor(white: 1.0, alpha: 0.4).cgColor,
            NSColor(white: 1.0, alpha: 0.7).cgColor,
        ]
        knobGradientLayer.locations = [
            0.0, 0.5, 0.5, 1.0
        ]
        knobGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        knobGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        knobLayer.addSublayer(knobGradientLayer)
    }
    
    
    /////////////////////////////////
    // MARK: - CALayerDelegate Method
    public func display(_ layer: CALayer) {
        let cornerRadius = frame.size.height * kCornerRadiusRatio
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = NSInsetRect(bounds, 1.0, 0.0)
        backgroundLayer.cornerRadius = cornerRadius
        
        backgroundGradientLayer.frame = backgroundLayer.bounds
        
        let knobWidth = bounds.size.width * 0.5
        knobLayer.frame = NSRect(
            x: state ? NSMaxX(bounds) - knobWidth : 0.0,
            y: 0.0,
            width: knobWidth,
            height: bounds.size.height)
        knobLayer.cornerRadius = cornerRadius
        
        knobGradientLayer.frame = knobLayer.bounds
        CATransaction.commit()
    }
    
    
    ////////////////////////////
    // MARK: - NSControl Methods
    public override func mouseDown(with theEvent: NSEvent) {
        if !isEnabled { return }
        
        activated = true
        
        let locationInSwitch = convert(theEvent.locationInWindow, from: nil)
        if NSPointInRect(locationInSwitch, knobLayer.frame) {
            clickedLocationInKnob = knobLayer.convert(locationInSwitch, from: layer)
            if clickedLocationInKnob!.x < kDraggingEdgeMargin {
                clickedLocationInKnob!.x = kDraggingEdgeMargin
            }
            else if clickedLocationInKnob!.x > NSMaxX(knobLayer.frame) - kDraggingEdgeMargin {
                clickedLocationInKnob!.x = NSMaxX(knobLayer.frame) - kDraggingEdgeMargin
            }
        }
        else {
            clickedLocationInKnob = nil
        }
    }
    
    public override func mouseDragged(with theEvent: NSEvent) {
        if !isEnabled { return }
        
        dragged = true
        let locationInWindow = theEvent.locationInWindow
        activated = true
        var x: CGFloat
        if let clickedLocationInKnob = clickedLocationInKnob, activated {
            let locationInSwitch = convert(locationInWindow, from: nil)
            x = locationInSwitch.x - clickedLocationInKnob.x
            if x < 0 {
                x = 0.0
            }
            else if x > NSMaxX(bounds) - NSWidth(knobLayer.frame) {
                x = NSMaxX(bounds) - NSWidth(knobLayer.frame)
            }
        }
        else {
            x = state ? NSMaxX(bounds) - NSWidth(knobLayer.frame) : 0.0
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        knobLayer.frame.origin.x = x
        CATransaction.commit()
    }
    
    public override func mouseUp(with theEvent: NSEvent) {
        if !isEnabled { return }
        
        if dragged && clickedLocationInKnob != nil {
            let oldState = state
            state = NSMidX(knobLayer.frame) > NSMidX(bounds)
            if state != oldState && action != nil {
                NSApp.sendAction(action!, to: target, from: self)
            }
        }
        else if isInside(event: theEvent) {
            state = !state
            if action != nil {
                NSApp.sendAction(action!, to: target, from: self)
            }
        }
        
        activated = false
        dragged = false
        clickedLocationInKnob = nil
    }
    
    // MARK:- Helpers
    private func isInside(event: NSEvent) -> Bool {
        let locationInSwitch = convert(event.locationInWindow, from: nil)
        return NSPointInRect(locationInSwitch, bounds)
    }
}
