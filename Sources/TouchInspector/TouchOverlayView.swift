//
//  TouchOverlayView.swift
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

class TouchOverlayView: UIView {

    lazy var touchIndicatorView = TouchIndicatorView(style: touchStyle)

    lazy var hitTestingOverlay = HitTestingOverlay()

    class TouchIndicatorView: UIVisualEffectView {

        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)

        init(style: TouchStyle) {
            super.init(effect: style.material.blurEffect)

            bounds = CGRect(x: 0, y: 0, width: style.size.width, height: style.size.height)
            backgroundColor = style.material.backgroundColor
            layer.borderWidth = style.border?.width ?? 0
            layer.borderColor = style.border?.color.cgColor ?? nil

            layer.cornerRadius = bounds.size.height / 2.0
            layer.masksToBounds = true
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class HitTestingOverlay: UIView {

        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        lazy var blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        lazy var vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect, style: .label))

        let margin: CGFloat = 10
        let maxWidth: CGFloat = 220
        let maxHeight: CGFloat = 1000

        private let textView: UILabel = {
            let textView = UILabel()
            textView.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
            textView.numberOfLines = 0
            return textView
        }()

        init() {
            super.init(frame: .zero)

            addSubview(blurVisualEffectView)
            blurVisualEffectView.contentView.addSubview(vibrancyEffectView)
            vibrancyEffectView.contentView.addSubview(textView)

            layer.cornerRadius = 12
            layer.cornerCurve = .continuous
            layer.masksToBounds = true
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        var text: String? {
            didSet {
                textView.text = text
            }
        }

        override var intrinsicContentSize: CGSize {
            let size = textView.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
            return CGSize(width: size.width + margin * 2, height: size.height + margin * 2)
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            blurVisualEffectView.frame = bounds
            vibrancyEffectView.frame = blurVisualEffectView.bounds
            textView.frame = vibrancyEffectView.contentView.bounds

            textView.frame.size = CGSize(width: bounds.size.width - (margin * 2), height: bounds.size.height - (margin * 2))
            textView.frame.origin = CGPoint(x: margin, y: margin)
        }
    }

    let touchStyle: TouchStyle

    init(style: TouchStyle) {
        self.touchStyle = style
        super.init(frame: .zero)

        addSubview(touchIndicatorView)
        addSubview(hitTestingOverlay)

        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Presentation

    func present() {
        alpha = 0
        touchIndicatorView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        animateBlock {
            self.alpha = 1
            self.touchIndicatorView.transform = .identity
        }
    }

    func hide(completion: @escaping (() -> Void)) {
        animateBlock {
            self.alpha = 0
            self.touchIndicatorView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: {
            completion()
        }
    }

    // MARK: - Hit Testing

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        nil
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let superview = superview else {
            return
        }

        // Touch Indicator
        touchIndicatorView.center = bounds.origin

        // Hit Test Overlay
        let labelIntrinsicContentSize = hitTestingOverlay.intrinsicContentSize

        let touchLocation = frame.origin
        let screenWidth = superview.bounds.size.width

        let labelWidth = labelIntrinsicContentSize.width

        let yPadding: CGFloat = 40

        var x: CGFloat = 0
        var y: CGFloat = yPadding

        if touchLocation.x + labelWidth > screenWidth {
            x = -labelIntrinsicContentSize.width
        }

        if (touchLocation.y + labelIntrinsicContentSize.height + yPadding) > superview.bounds.size.height {
            y = -labelIntrinsicContentSize.height - yPadding
        }

        hitTestingOverlay.frame = CGRect(x: x, y: y, width: labelIntrinsicContentSize.width, height: labelIntrinsicContentSize.height)
    }

}
