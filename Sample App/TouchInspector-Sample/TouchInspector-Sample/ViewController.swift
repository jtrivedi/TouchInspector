//
//  ViewController.swift
//  TouchInspector-Sample
//
//  Created by Janum Trivedi.
//

import Foundation
import UIKit
import TouchInspector

class ViewController: UIViewController {
    
    var sheetView: SheetView!
    
    override func viewDidLoad() {
        sheetView = SheetView(maxWidth: view.bounds.size.width * 0.7)
        view.addSubview(sheetView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sheetView.frame = view.bounds
    }
}

class SheetView: UIView {
    
    init(maxWidth: CGFloat) {
        super.init(frame: .zero)
        
        backgroundColor = .systemGray5
        
        buildTouchIndicatorButton(maxWidth)
        buildHitTestingButton(maxWidth)
        
        var yOffset: CGFloat = 146
        for i in 2...15 {
            let randomWidth = CGFloat(Int.random(in: 40...Int(maxWidth)))
            
            let placeholder = PlaceholderView(frame: CGRect(x: 30.0, y: yOffset, width: randomWidth, height: 32))
            addSubview(placeholder)
            
            let sectionBreak = (i + 1) % 3 == 0 ? 40.0 : 0.0
            yOffset += (placeholder.bounds.size.height * 1.5 + sectionBreak)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildTouchIndicatorButton(_ maxWidth: CGFloat) {
        let randomWidth = CGFloat(Int.random(in: 180...Int(maxWidth)))
        let touchesButton = ButtonView(frame: CGRect(x: 30.0, y: 50, width: randomWidth, height: 32),
                                       title: "Toggle Touches",
                                       // default is true because window?.windowScene?.delegate is nil ATM
                                       status: true) {
            guard let sceneDelegate = self.window?.windowScene?.delegate as? SceneDelegate,
                  let window = sceneDelegate.window as? TouchInspectorWindow else {
                return false
            }
            window.showTouches = !window.showTouches
            return window.showTouches
        }
        addSubview(touchesButton)
    }
    
    private func buildHitTestingButton(_ maxWidth: CGFloat) {
        let randomWidth = CGFloat(Int.random(in: 230...Int(maxWidth)))
        let hitTestingButton = ButtonView(frame: CGRect(x: 30.0, y: 98, width: randomWidth, height: 32),
                                          title: "Toggle Hit Testing",
                                          // default is true because window?.windowScene?.delegate is nil ATM
                                          status: true) {
            guard let sceneDelegate = self.window?.windowScene?.delegate as? SceneDelegate,
                  let window = sceneDelegate.window as? TouchInspectorWindow else {
                return false
            }
            window.showHitTesting = !window.showHitTesting
            return window.showHitTesting
        }
        addSubview(hitTestingButton)
    }
}

class PlaceholderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let colors: [UIColor] = [.systemRed, .systemYellow, .systemOrange, .systemPink, .systemPurple, .systemBlue]
        backgroundColor = colors.randomElement()?.withAlphaComponent(0.5)
    
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ButtonView: PlaceholderView {
    private var buttonAction: () -> Bool
    private var statusLabel: UILabel!
    
    init(frame: CGRect, title: String, status: Bool, action: @escaping () -> Bool) {
        buttonAction = action
        super.init(frame: frame)
        
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: topAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        statusLabel = UILabel()
        statusLabel.text = status ? "✅" : "❌"
        statusLabel.textAlignment = .center
        addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: button.trailingAnchor).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func buttonPressed(_ sender: UIControl) {
        let newStatus = buttonAction()
        
        if newStatus {
            statusLabel.text = "✅"
        } else {
            statusLabel.text = "❌"
        }
    }
}
