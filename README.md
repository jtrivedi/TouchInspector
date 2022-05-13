![TouchInspector Banner](Banner.png?raw=true "TouchInspector Banner")

# TouchInspector

TouchInspector is a lightweight package that helps you visualize and debug touches on iOS and iPadOS.

Showing touches is super useful when recording and sharing demos from a device or Simulator.

TouchInspector can optionally also show hit-testing information (i.e. which view a touch is hitting). This is great when trying to identify the type of some view, or debug where a touch is actually going.

#### Installation

Add TouchInspector to your app's `Package.swift` file, or selecting `File -> Add Packages` in Xcode:

```swift
.package(url: "https://github.com/jtrivedi/TouchInspector", from: "0.1.0"))
```
#### Usage

You'll need to change the type of your application/scene's `window` to `TouchInspectorWindow`, which you can do conditionally when developing:

```swift
import TouchInspector

func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else {
        return
    }
    
    let rootViewController = /* Create your root/initial view controller, 
                                either directly or by extracting from a Storyboard */
    #if DEBUG
    window = TouchInspectorWindow(windowScene: windowScene)
    #else
    window = UIWindow(windowScene: windowScene)
    #endif
    
    window?.rootViewController = initialViewController
    window?.makeKeyAndVisible()
}
```

Touch **and** hit-testing visualization is enabled by default when creating a `TouchInspectorWindow`. You can change that with the following properties:

```swift
// Show the touch indicator, but not the hit-testing overlay.
window.showTouches = true
window.showHitTesting = false
```
