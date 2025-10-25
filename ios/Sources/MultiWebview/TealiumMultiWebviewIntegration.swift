//
//  TealiumMultiWebviewIntegration.swift
//  MsAppMultiWebview
//
//  Integration layer between Tealium Tag Management and Multi-Webview Plugin
//

#if os(iOS)
import Foundation
import Capacitor
import WebKit
import UIKit

/// Integration class that bridges Tealium Tag Management with Multi-Webview Plugin
/// This allows the Tealium webview to be managed through the multi-webview plugin API
class TealiumMultiWebviewIntegration {

    static let shared = TealiumMultiWebviewIntegration()

    // Reserved webview ID for Tealium
    static let tealiumWebviewId = "tealium-tag-manager"

    private weak var manager: MsAppMultiWebviewManager?
    private weak var plugin: CAPPlugin?
    private var tealiumWebview: WKWebView?

    private init() {}

    /// Configure the integration with the multi-webview manager and plugin
    ///
    /// - Parameters:
    ///   - manager: The MsAppMultiWebviewManager instance
    ///   - plugin: The plugin instance for notifications
    func configure(manager: MsAppMultiWebviewManager, plugin: CAPPlugin) {
        self.manager = manager
        self.plugin = plugin
    }

    /// Register a Tealium webview with the multi-webview manager
    /// This allows the Tealium webview to be controlled via the multi-webview plugin API
    ///
    /// - Parameters:
    ///   - webview: The WKWebView instance used by Tealium
    ///   - url: The URL loaded in the webview (typically mobile.html)
    ///   - frame: Optional frame for the webview
    /// - Returns: Bool indicating success or failure
    @discardableResult
    func registerTealiumWebview(_ webview: WKWebView, url: String? = nil, frame: CGRect? = nil) -> Bool {
        guard let manager = manager else {
            return false
        }

        self.tealiumWebview = webview

        // Check if already registered
        if manager.webviewExists(id: TealiumMultiWebviewIntegration.tealiumWebviewId) {
            // Update existing registration
            return updateTealiumWebview(webview, url: url)
        }

        // Register new webview with the manager
        // We bypass the normal createWebview method since Tealium creates its own webview
        do {
            try manager.registerExternalWebview(
                id: TealiumMultiWebviewIntegration.tealiumWebviewId,
                webview: webview,
                url: url
            )

            // Notify listeners
            plugin?.notifyListeners("webviewCreated", data: ["id": TealiumMultiWebviewIntegration.tealiumWebviewId])

            return true
        } catch {
            return false
        }
    }

    /// Update the Tealium webview registration (e.g., when URL changes)
    ///
    /// - Parameters:
    ///   - webview: The updated WKWebView instance
    ///   - url: The new URL
    /// - Returns: Bool indicating success
    private func updateTealiumWebview(_ webview: WKWebView, url: String?) -> Bool {
        guard let manager = manager else {
            return false
        }

        self.tealiumWebview = webview

        do {
            try manager.updateWebviewUrl(
                id: TealiumMultiWebviewIntegration.tealiumWebviewId,
                url: url
            )
            return true
        } catch {
            return false
        }
    }

    /// Unregister the Tealium webview from the multi-webview manager
    func unregisterTealiumWebview() {
        guard let manager = manager else {
            return
        }

        do {
            try manager.destroyWebview(id: TealiumMultiWebviewIntegration.tealiumWebviewId)
            plugin?.notifyListeners("webviewDestroyed", data: ["id": TealiumMultiWebviewIntegration.tealiumWebviewId])
        } catch {
            // Already unregistered or doesn't exist
        }

        self.tealiumWebview = nil
    }

    /// Get the Tealium webview ID for use with multi-webview plugin methods
    ///
    /// - Returns: The reserved webview ID for Tealium
    static func getTealiumWebviewId() -> String {
        return tealiumWebviewId
    }

    /// Check if the Tealium webview is currently registered
    ///
    /// - Returns: Bool indicating if Tealium webview is registered
    func isTealiumWebviewRegistered() -> Bool {
        guard let manager = manager else {
            return false
        }
        return manager.webviewExists(id: TealiumMultiWebviewIntegration.tealiumWebviewId)
    }
}

/// Extension to MsAppMultiWebviewManager to support external webview registration
extension MsAppMultiWebviewManager {

    /// Register an externally created webview (e.g., from Tealium)
    /// This allows third-party webviews to be managed through the multi-webview plugin
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the webview
    ///   - webview: Pre-existing WKWebView instance
    ///   - url: Current or initial URL
    /// - Throws: MsAppMultiWebviewError if webview with ID already exists
    func registerExternalWebview(id: String, webview: WKWebView, url: String?) throws {
        if webviews[id] != nil {
            throw MsAppMultiWebviewError.webviewAlreadyExists
        }

        let container = WebviewContainer(id: id, webView: webview)
        container.currentUrl = url
        webviews[id] = container
    }

    /// Update the URL for an existing webview
    ///
    /// - Parameters:
    ///   - id: Identifier of the webview
    ///   - url: New URL
    /// - Throws: MsAppMultiWebviewError if webview not found
    func updateWebviewUrl(id: String, url: String?) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }
        container.currentUrl = url
    }

    /// Check if a webview with the given ID exists
    ///
    /// - Parameter id: Webview identifier
    /// - Returns: Bool indicating if webview exists
    func webviewExists(id: String) -> Bool {
        return webviews[id] != nil
    }
}

#endif
