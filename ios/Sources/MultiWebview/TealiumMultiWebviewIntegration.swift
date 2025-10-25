//
//  TealiumMultiWebviewIntegration.swift
//  MsAppMultiWebview
//
//  Integration helper for Tealium Tag Management with Multi-Webview Plugin
//  This integration does NOT modify any Tealium source files - it uses their public API
//

#if os(iOS)
import Foundation
import Capacitor
import WebKit
import UIKit

/// Integration helper that enables Tealium Tag Management webview to be managed
/// through the Multi-Webview Plugin without modifying Tealium source code.
///
/// Usage:
/// ```swift
/// // After initializing Tealium
/// TealiumMultiWebviewIntegration.shared.integrateWith(
///     tealiumInstance: tealium,
///     manager: multiWebviewManager,
///     plugin: multiWebviewPlugin
/// )
/// ```
public class TealiumMultiWebviewIntegration {

    public static let shared = TealiumMultiWebviewIntegration()

    /// Reserved webview ID for Tealium
    public static let tealiumWebviewId = "tealium-tag-manager"

    private weak var manager: MsAppMultiWebviewManager?
    private weak var plugin: CAPPlugin?
    private var isIntegrated = false

    private init() {}

    /// Integrate Tealium webview with Multi-Webview plugin
    ///
    /// This method uses Tealium's public `getWebView()` API to obtain the webview
    /// and register it with the Multi-Webview plugin manager.
    ///
    /// - Parameters:
    ///   - tealiumModule: The Tealium TagManagementProtocol instance (usually from tealium.tagManagement)
    ///   - manager: The MsAppMultiWebviewManager instance
    ///   - plugin: The MsAppMultiWebviewPlugin instance for notifications
    ///   - completion: Optional completion handler called after integration
    ///
    /// - Example:
    /// ```swift
    /// if let tagManagement = tealium.modules.first(where: { $0.id == "tagmanagement" }) as? TagManagementModule {
    ///     TealiumMultiWebviewIntegration.shared.integrateWith(
    ///         tealiumModule: tagManagement.tagManagement,
    ///         manager: multiWebviewPlugin.manager,
    ///         plugin: multiWebviewPlugin
    ///     ) { success in
    ///         print("Tealium integration: \(success ? "success" : "failed")")
    ///     }
    /// }
    /// ```
    public func integrateWith(
        tealiumModule: Any,
        manager: MsAppMultiWebviewManager,
        plugin: CAPPlugin,
        completion: ((Bool) -> Void)? = nil
    ) {
        self.manager = manager
        self.plugin = plugin

        // Use Tealium's getWebView() method via protocol
        guard let tagManagement = tealiumModule as? TagManagementProtocol else {
            completion?(false)
            return
        }

        // Get the webview using Tealium's public API
        tagManagement.getWebView { [weak self] webview in
            guard let self = self else {
                completion?(false)
                return
            }

            let url = tagManagement.url?.absoluteString

            do {
                // Check if already registered
                if manager.webviewExists(id: TealiumMultiWebviewIntegration.tealiumWebviewId) {
                    try manager.updateWebviewUrl(
                        id: TealiumMultiWebviewIntegration.tealiumWebviewId,
                        url: url
                    )
                } else {
                    // Register the webview
                    try manager.registerExternalWebview(
                        id: TealiumMultiWebviewIntegration.tealiumWebviewId,
                        webview: webview,
                        url: url
                    )

                    // Notify listeners
                    plugin.notifyListeners("webviewCreated", data: [
                        "id": TealiumMultiWebviewIntegration.tealiumWebviewId
                    ])
                }

                self.isIntegrated = true
                completion?(true)
            } catch {
                completion?(false)
            }
        }
    }

    /// Manually register a Tealium webview (if you have direct access to it)
    ///
    /// - Parameters:
    ///   - webview: The WKWebView instance from Tealium
    ///   - manager: The MsAppMultiWebviewManager instance
    ///   - plugin: The plugin instance for notifications
    ///   - url: Optional URL loaded in the webview
    /// - Returns: Bool indicating success
    @discardableResult
    public func registerWebview(
        _ webview: WKWebView,
        manager: MsAppMultiWebviewManager,
        plugin: CAPPlugin,
        url: String? = nil
    ) -> Bool {
        self.manager = manager
        self.plugin = plugin

        do {
            // Check if already registered
            if manager.webviewExists(id: TealiumMultiWebviewIntegration.tealiumWebviewId) {
                try manager.updateWebviewUrl(
                    id: TealiumMultiWebviewIntegration.tealiumWebviewId,
                    url: url
                )
            } else {
                try manager.registerExternalWebview(
                    id: TealiumMultiWebviewIntegration.tealiumWebviewId,
                    webview: webview,
                    url: url
                )

                plugin.notifyListeners("webviewCreated", data: [
                    "id": TealiumMultiWebviewIntegration.tealiumWebviewId
                ])
            }

            isIntegrated = true
            return true
        } catch {
            return false
        }
    }

    /// Unregister the Tealium webview from multi-webview management
    ///
    /// Call this when you want to stop managing the Tealium webview through
    /// the Multi-Webview plugin, typically when disabling Tealium.
    public func unregister() {
        guard let manager = manager, let plugin = plugin else {
            return
        }

        do {
            try manager.destroyWebview(id: TealiumMultiWebviewIntegration.tealiumWebviewId)
            plugin.notifyListeners("webviewDestroyed", data: [
                "id": TealiumMultiWebviewIntegration.tealiumWebviewId
            ])
        } catch {
            // Already unregistered or doesn't exist
        }

        isIntegrated = false
    }

    /// Get the Tealium webview ID used for multi-webview plugin operations
    ///
    /// - Returns: The reserved webview ID for Tealium
    public static func getTealiumWebviewId() -> String {
        return tealiumWebviewId
    }

    /// Check if Tealium webview is currently integrated
    ///
    /// - Returns: Bool indicating if integration is active
    public func isIntegratedWithMultiWebview() -> Bool {
        guard let manager = manager else {
            return false
        }
        return isIntegrated && manager.webviewExists(id: TealiumMultiWebviewIntegration.tealiumWebviewId)
    }
}

/// Protocol mirror for TagManagementProtocol to avoid direct dependency
/// This allows the integration to work without importing TealiumCore
private protocol TagManagementProtocol {
    func getWebView(_ completion: @escaping (WKWebView) -> Void)
    var url: URL? { get }
}

/// Extension to MsAppMultiWebviewManager to support external webview registration
extension MsAppMultiWebviewManager {

    /// Register an externally created webview (e.g., from Tealium)
    ///
    /// This allows third-party webviews to be managed through the multi-webview plugin
    /// without the plugin being responsible for creating them.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the webview
    ///   - webview: Pre-existing WKWebView instance
    ///   - url: Current or initial URL (optional)
    /// - Throws: MsAppMultiWebviewError if webview with ID already exists
    @objc func registerExternalWebview(id: String, webview: WKWebView, url: String?) throws {
        if webviews[id] != nil {
            throw MsAppMultiWebviewError.webviewAlreadyExists
        }

        let container = WebviewContainer(id: id, webView: webview)
        container.currentUrl = url
        webviews[id] = container
    }

    /// Update the URL for an existing webview
    ///
    /// Useful for external webviews where the URL may change independently
    /// of the multi-webview plugin's loadUrl method.
    ///
    /// - Parameters:
    ///   - id: Identifier of the webview
    ///   - url: New URL string (optional)
    /// - Throws: MsAppMultiWebviewError if webview not found
    @objc func updateWebviewUrl(id: String, url: String?) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }
        container.currentUrl = url
    }

    /// Check if a webview with the given ID exists
    ///
    /// - Parameter id: Webview identifier
    /// - Returns: Bool indicating if webview is registered
    @objc func webviewExists(id: String) -> Bool {
        return webviews[id] != nil
    }
}

#endif
