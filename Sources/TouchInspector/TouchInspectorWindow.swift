//
//  TouchInspectorWindow.swift
//
//  Copyright 2022 Janum Trivedi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import UIKit

public class TouchInspectorWindow: UIWindow {
    
    /**
     Whether to show the circular touch indicator.
     */
    public var showTouches: Bool = true {
        didSet {
            hideOverlaysIfNeeded()
        }
    }
    
    /**
     Whether to show the hit-test debugging overlay. If enabled, touch indicators will also be shown.
     */
    public var showHitTesting: Bool = true {
        didSet {
            hideOverlaysIfNeeded()
        }
    }
    
    private var touchOverlays: [UITouch : TouchOverlayView] = [:]
    
    public override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Event Handling
    
    public override func sendEvent(_ event: UIEvent) {
        handleTouchesEvent(event)
        super.sendEvent(event)
    }
    
    // MARK: - Private
    
    private func handleTouchesEvent(_ touchesEvent: UIEvent) {
        guard showTouches || showHitTesting else {
            return
        }
        
        guard touchesEvent.type == .touches else {
            return
        }
        
        for touch in touchesEvent.allTouches ?? [] {
            let touchLocationInWindow = touch.location(in: self)
            let touchPhase = touch.phase
            
            if touchPhase == .began {
                createTouchOverlay(for: touch)
            }
            
            updateTouchOverlay(
                for: touch,
                location: touchLocationInWindow,
                hitTestedView: hitTest(touchLocationInWindow, with: touchesEvent)
            )
            
            if touchPhase == .ended || touchPhase == .cancelled {
                removeTouchOverlay(for: touch)
            }
        }
    }
    
    private func createTouchOverlay(for touch: UITouch) {
        let overlay = TouchOverlayView()
        touchOverlays[touch] = overlay
        
        addSubview(overlay)
        overlay.present()
    }

    private func updateTouchOverlay(for touch: UITouch, location: CGPoint, hitTestedView: UIView?) {
        guard let overlay = touchOverlays[touch] else {
            return
        }
        
        overlay.hitTestingOverlay.text = hitTestOverlayDescription(for: location, hitTestedView: hitTestedView)
        overlay.hitTestingOverlay.isHidden = !showHitTesting
        
        overlay.frame.origin = location
        overlay.setNeedsLayout()
        
        bringSubviewToFront(overlay)
    }
    
    private func removeTouchOverlay(for touch: UITouch) {
        guard let overlay = touchOverlays[touch] else {
            return
        }
        
        overlay.hide(completion: {
            overlay.removeFromSuperview()
            self.touchOverlays.removeValue(forKey: touch)
        })
    }
    
    private func hitTestOverlayDescription(for locationInWindow: CGPoint, hitTestedView: UIView?) -> String {
        let locationInWindowDescription = locationInWindow.shortDescription
        
        let locationInHitTestedView = self.convert(locationInWindow, to: hitTestedView)
        let locationInHitTestedViewDescription = locationInHitTestedView.shortDescription
        
        return """
        Touch:   \(locationInWindowDescription)
        In View: \(locationInHitTestedViewDescription)

        Hit-Test: \(hitTestedView?.description ?? "nil")
        """
    }
    
    private func hideOverlaysIfNeeded() {
        if !showTouches && !showHitTesting {
            touchOverlays.values.forEach { overlay in
                overlay.removeFromSuperview()
            }
            touchOverlays = [:]
        } else if showTouches {
            touchOverlays.values.forEach { overlay in
                overlay.hitTestingOverlay.isHidden = !showHitTesting
            }
        }
        
    }
}
