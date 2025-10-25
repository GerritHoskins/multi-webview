import Foundation
import Capacitor
import WebKit
import UIKit

enum MsAppMultiWebviewError: Error {
    case webviewAlreadyExists
    case webviewNotFound
    case invalidURL
    case noViewController
}

class WebviewContainer {
    let id: String
    let webView: WKWebView
    var isHidden: Bool = false
    var currentUrl: String?

    init(id: String, webView: WKWebView) {
        self.id = id
        self.webView = webView
    }
}

class MsAppMultiWebviewManager: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    weak var plugin: CAPPlugin?
    private var webviews: [String: WebviewContainer] = [:]
    private var focusedWebviewId: String?

    func createWebview(
        id: String,
        url: String?,
        frame: CGRect?,
        autoFocus: Bool,
        enableJavaScript: Bool,
        allowFileAccess: Bool,
        userAgent: String?
    ) throws {
        if webviews[id] != nil {
            throw MsAppMultiWebviewError.webviewAlreadyExists
        }

        guard let viewController = plugin?.bridge?.viewController else {
            throw MsAppMultiWebviewError.noViewController
        }

        // Configure webview
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = enableJavaScript

        // Add message handler for receiving messages from webview
        let contentController = WKUserContentController()
        contentController.add(self, name: "multiWebviewMessageHandler")
        config.userContentController = contentController

        // Determine frame
        let webviewFrame = frame ?? viewController.view.bounds

        // Create webview
        let webView = WKWebView(frame: webviewFrame, configuration: config)
        webView.navigationDelegate = self
        webView.tag = id.hashValue

        if let userAgent = userAgent {
            webView.customUserAgent = userAgent
        }

        // Allow file access if requested
        if allowFileAccess {
            // Note: File access configuration may require additional setup
        }

        // Add to view hierarchy
        viewController.view.addSubview(webView)

        // Store webview container
        let container = WebviewContainer(id: id, webView: webView)
        webviews[id] = container

        // Load URL if provided
        if let urlString = url {
            try loadUrl(id: id, urlString: urlString)
        }

        // Set focus if requested
        if autoFocus {
            try setFocusedWebview(id: id)
        } else if focusedWebviewId == nil {
            // If no webview is focused and this is the first one, focus it
            if webviews.count == 1 {
                try setFocusedWebview(id: id)
            } else {
                // Send to back if not auto-focusing
                webView.isHidden = true
                container.isHidden = true
            }
        } else {
            // Send to back if not auto-focusing
            viewController.view.sendSubviewToBack(webView)
            webView.isHidden = true
            container.isHidden = true
        }
    }

    func setFocusedWebview(id: String) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }

        guard let viewController = plugin?.bridge?.viewController else {
            throw MsAppMultiWebviewError.noViewController
        }

        // Hide all other webviews
        for (otherId, otherContainer) in webviews where otherId != id {
            otherContainer.webView.isHidden = true
            otherContainer.isHidden = true
        }

        // Show and bring to front the focused webview
        container.webView.isHidden = false
        container.isHidden = false
        viewController.view.bringSubviewToFront(container.webView)

        focusedWebviewId = id
    }

    func getFocusedWebviewId() -> String? {
        return focusedWebviewId
    }

    func hideWebview(id: String) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }

        container.webView.isHidden = true
        container.isHidden = true

        if focusedWebviewId == id {
            focusedWebviewId = nil
        }
    }

    func showWebview(id: String) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }

        container.webView.isHidden = false
        container.isHidden = false
    }

    func destroyWebview(id: String) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }

        container.webView.removeFromSuperview()
        webviews.removeValue(forKey: id)

        if focusedWebviewId == id {
            focusedWebviewId = nil
        }
    }

    func loadUrl(id: String, urlString: String) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }

        guard let url = URL(string: urlString) else {
            throw MsAppMultiWebviewError.invalidURL
        }

        let request = URLRequest(url: url)
        container.webView.load(request)
    }

    func listWebviews() -> [String] {
        return Array(webviews.keys)
    }

    func getWebviewInfo(id: String) throws -> [String: Any?] {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }

        return [
            "id": id,
            "url": container.currentUrl as Any?,
            "isHidden": container.isHidden,
            "isFocused": focusedWebviewId == id
        ]
    }

    func getAllWebviews() -> [[String: Any?]] {
        return webviews.map { (id, container) in
            return [
                "id": id,
                "url": container.currentUrl as Any?,
                "isHidden": container.isHidden,
                "isFocused": focusedWebviewId == id
            ]
        }
    }

    func getWebviewsByUrl(urlString: String, exactMatch: Bool) -> [String] {
        return webviews.compactMap { (id, container) in
            guard let currentUrl = container.currentUrl else {
                return nil
            }

            if exactMatch {
                return currentUrl == urlString ? id : nil
            } else {
                return currentUrl.contains(urlString) ? id : nil
            }
        }
    }

    func setWebviewFrame(id: String, frame: CGRect) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }

        container.webView.frame = frame
    }

    func executeJavaScript(id: String, code: String, completion: @escaping (Any?, Error?) -> Void) {
        guard let container = webviews[id] else {
            completion(nil, MsAppMultiWebviewError.webviewNotFound)
            return
        }

        container.webView.evaluateJavaScript(code) { result, error in
            completion(result, error)
        }
    }

    func sendMessage(id: String, data: Any) throws {
        guard let container = webviews[id] else {
            throw MsAppMultiWebviewError.webviewNotFound
        }

        // Convert data to JSON string
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw MsAppMultiWebviewError.webviewNotFound // Use a better error
        }

        // Escape the JSON string for JavaScript
        let escapedJson = jsonString.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")

        // Inject JavaScript to dispatch a custom event
        let script = """
        (function() {
            var event = new CustomEvent('multiwebview-message', {
                detail: JSON.parse('\(escapedJson)')
            });
            window.dispatchEvent(event);
        })();
        """

        container.webView.evaluateJavaScript(script, completionHandler: nil)
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let id = findWebviewId(for: webView), let url = webView.url?.absoluteString {
            plugin?.notifyListeners("loadStart", data: ["id": id, "url": url])
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let id = findWebviewId(for: webView), let url = webView.url?.absoluteString {
            // Update the current URL in the container
            if let container = webviews[id] {
                container.currentUrl = url
            }
            plugin?.notifyListeners("loadFinish", data: ["id": id, "url": url])
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if let id = findWebviewId(for: webView), let url = webView.url?.absoluteString {
            plugin?.notifyListeners("loadError", data: [
                "id": id,
                "url": url,
                "error": error.localizedDescription
            ])
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let id = findWebviewId(for: webView), let url = webView.url?.absoluteString {
            plugin?.notifyListeners("loadError", data: [
                "id": id,
                "url": url,
                "error": error.localizedDescription
            ])
        }
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "multiWebviewMessageHandler" {
            if let webView = message.webView, let id = findWebviewId(for: webView) {
                plugin?.notifyListeners("message", data: [
                    "id": id,
                    "data": message.body
                ])
            }
        }
    }

    // MARK: - Helper methods

    private func findWebviewId(for webView: WKWebView) -> String? {
        for (id, container) in webviews {
            if container.webView === webView {
                return id
            }
        }
        return nil
    }
}
