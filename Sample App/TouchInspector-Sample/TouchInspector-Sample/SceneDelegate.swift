//
//  SceneDelegate.swift
//  TouchInspector
//
//  Created by Janum Trivedi.
//

import UIKit
import TouchInspector

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        #if DEBUG
        window = TouchInspectorWindow(windowScene: windowScene)
        if let window = window as? TouchInspectorWindow {
            window.showTouches = true
            window.showHitTesting = false

            // Optional style customization
//            window.touchStyle = TouchStyle(
//                material: .color(.white.withAlphaComponent(0.6)),
//                size: CGSize(width: 50, height: 50),
//                border: TouchStyle.Border(color: .systemBlue, width: 3)
//            )
        }
        #else
        window = UIWindow(windowScene: windowScene)
        #endif

        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
    }

}
