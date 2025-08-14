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

public struct TouchStyle: Equatable {

    public static var blueBordered = TouchStyle(
        material: .color(.systemBlue.withAlphaComponent(0.6)),
        size: CGSize(width: 48, height: 48),
        border: TouchStyle.Border(color: .systemBlue, width: 3)
    )

    public static var materialDot = TouchStyle(
        material: .materialBlur,
        size: CGSize(width: 32, height: 32),
        border: nil
    )

    public enum Material: Equatable {
        case materialBlur
        case color(UIColor)

        var blurEffect: UIBlurEffect? {
            switch self {
            case .materialBlur:
                return UIBlurEffect(style: .systemThinMaterialDark)
            default:
                return nil
            }
        }

        var backgroundColor: UIColor? {
            switch self {
            case .materialBlur:
                return nil
            case .color(let color):
                return color
            }
        }
    }

    public struct Border: Equatable {
        let color: UIColor
        let width: CGFloat

        public init(color: UIColor, width: CGFloat) {
            self.color = color
            self.width = width
        }
    }

    let material: Material
    let size: CGSize
    let border: Border?

    public init(
        material: Material,
        size: CGSize,
        border: Border? = nil) {
        self.material = material
        self.size = size
        self.border = border
    }
}

public class TouchInspectorWindow: UIWindow {

    /**
     Whether to show the circular touch indicator.
     */
    public var showTouches: Bool = true

    /**
     Whether to show the hit-test debugging overlay. If enabled, touch indicators will also be shown.
     */
    public var showHitTesting: Bool = true

    /**
     The visual style of the touch indicator view. Configurable by creating a custom `TouchStyle`.
     */
    public var touchStyle = TouchStyle.blueBordered

    private var touchOverlays: [UITouch: TouchOverlayView] = [:]

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
                createTouchOverlay(for: touch, with: touchStyle)
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

    private func createTouchOverlay(for touch: UITouch, with style: TouchStyle) {
        let overlay = TouchOverlayView(style: style)
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

        if overlay.frame == .zero {
            overlay.frame.origin = location
            overlay.setNeedsLayout()
        }

        if #available(iOS 17.0, *) {
            UIView.animate(springDuration: 0.1, bounce: 0.1) {
                overlay.frame.origin = location
                overlay.setNeedsLayout()
            }
        } else {
            overlay.frame.origin = location
            overlay.setNeedsLayout()
        }

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
}
