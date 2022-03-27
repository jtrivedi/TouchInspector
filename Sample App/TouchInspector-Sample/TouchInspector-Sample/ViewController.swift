//
//  ViewController.swift
//  TouchInspector-Sample
//
//  Created by Janum Trivedi.
//

import Foundation
import UIKit

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
        
        var yOffset: CGFloat = 50.0
        for i in 0...15 {
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
