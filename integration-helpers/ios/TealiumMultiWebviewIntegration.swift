//
//  TealiumMultiWebviewIntegration.swift
//
//  Integration helper for using Tealium Tag Management with Multi-Webview Plugin
//
//  INSTALLATION:
//  1. Copy this file to your iOS app project (e.g., App/App/)
//  2. Ensure it's added to your app target, not the plugin
//
//  USAGE:
//  After both Tealium and Capacitor are initialized, call:
//
//     TealiumMultiWebviewBridge.integrate(
//         tealiumWebview: tealiumWebView,  // Get from Tealium
//         tealiumURL: "https://tags.tiqcdn.com/...",
//         bridge: self.bridge!
//     )
//
//  Then control from JavaScript using webview ID: "tealium-tag-manager"
//
//  Created with Claude Code
//

#if os(iOS)
import Foundation
import Capacitor
import WebKit

/// Simple bridge to integrate Tealium webview with Multi-Webview plugin
///
/// This enables managing the Tealium Tag Management webview through
/// the Multi-Webview Capacitor plugin API.
public class TealiumMultiWebviewBridge {

    /// Reserved webview ID for Tealium (use this ID in JavaScript)
    public static let tealiumWebviewId = "tealium-tag-manager"

    /// Integrate Tealium webview with Multi-Webview plugin
    ///
    /// Call this after both Tealium and the Capacitor bridge are ready.
    ///
    /// - Parameters:
    ///   - tealiumWebview: The WKWebView from Tealium Tag Management
    ///   - tealiumURL: Optional URL loaded in the Tealium webview
    ///   - bridge: Your Capacitor bridge instance
    /// - Returns: True if integration succeeded
    ///
    /// - Example:
    /// ```swift
    /// // Get Tealium webview (method depends on your Tealium setup)
    /// let tealiumWV = getTealiumWebview() // Your method
    ///
    /// // Integrate with Multi-Webview plugin
    /// let success = TealiumMultiWebviewBridge.integrate(
    ///     tealiumWebview: tealiumWV,
    ///     tealiumURL: "https://tags.tiqcdn.com/utag/account/profile/mobile.html",
    ///     bridge: bridge
    /// )
    ///
    /// if success {
    ///     print("✅ Tealium integrated - use ID 'tealium-tag-manager' in JS")
    /// }
    /// ```
    @discardableResult
    public static func integrate(
        tealiumWebview: WKWebView,
        tealiumURL: String? = nil,
        bridge: CAPBridgeProtocol
    ) -> Bool {
        // Get the Multi-Webview plugin from bridge
        guard let plugin = bridge.getPlugin(withName: "MsAppMultiWebview") as? NSObject else {
            print("❌ TealiumBridge: Multi-Webview plugin not found")
            return false
        }

        // Get the manager property using KVC
        guard let manager = plugin.value(forKey: "manager") as? NSObject else {
            print("❌ TealiumBridge: Could not access plugin manager")
            return false
        }

        // Call registerExternalWebview method
        let selector = NSSelectorFromString("registerExternalWebviewWithId:webview:url:")

        if manager.responds(to: selector) {
            // Invoke the method
            _ = manager.perform(selector, with: tealiumWebviewId, with: tealiumWebview, with: tealiumURL)

            // Notify listeners
            if plugin.responds(to: NSSelectorFromString("notifyListeners:data:")) {
                let data: [String: Any] = ["id": tealiumWebviewId]
                plugin.perform(NSSelectorFromString("notifyListeners:data:"), with: "webviewCreated", with: data)
            }

            print("✅ Tealium webview registered with Multi-Webview plugin")
            print("   JavaScript ID: '\(tealiumWebviewId)'")
            return true
        } else {
            print("❌ TealiumBridge: registerExternalWebview method not available")
            print("   Make sure you're using the latest version of Multi-Webview plugin")
            return false
        }
    }

    /// Unregister Tealium from Multi-Webview management
    ///
    /// - Parameter bridge: Your Capacitor bridge instance
    public static func unregister(bridge: CAPBridgeProtocol) {
        guard let plugin = bridge.getPlugin(withName: "MsAppMultiWebview") as? NSObject,
              let manager = plugin.value(forKey: "manager") as? NSObject else {
            return
        }

        // Call destroyWebview
        let selector = NSSelectorFromString("destroyWebviewWithId:")
        if manager.responds(to: selector) {
            _ = manager.perform(selector, with: tealiumWebviewId)

            // Notify
            if plugin.responds(to: NSSelectorFromString("notifyListeners:data:")) {
                let data: [String: Any] = ["id": tealiumWebviewId]
                plugin.perform(NSSelectorFromString("notifyListeners:data:"), with: "webviewDestroyed", with: data)
            }

            print("✅ Tealium webview unregistered")
        }
    }
}

#endif
