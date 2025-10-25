import Foundation
import Capacitor
import WebKit

@objc(MsAppMultiWebviewPlugin)
public class MsAppMultiWebviewPlugin: CAPPlugin {

    private let manager = MsAppMultiWebviewManager()
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "createWebview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setFocusedWebview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getFocusedWebview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "hideWebview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "showWebview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "destroyWebview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "loadUrl", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "listWebviews", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getWebviewInfo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getAllWebviews", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getWebviewsByUrl", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setWebviewFrame", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "executeJavaScript", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sendMessage", returnType: CAPPluginReturnPromise),
    ]

    override public func load() {
        manager.plugin = self
        super.load()
    }

    @objc func createWebview(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        let url = call.getString("url")
        let autoFocus = call.getBool("autoFocus") ?? true
        let enableJavaScript = call.getBool("enableJavaScript") ?? true
        let allowFileAccess = call.getBool("allowFileAccess") ?? false
        let userAgent = call.getString("userAgent")

        var frame: CGRect?
        if let frameObj = call.getObject("frame") {
            let x = frameObj["x"] as? Double ?? 0
            let y = frameObj["y"] as? Double ?? 0
            let width = frameObj["width"] as? Double ?? 0
            let height = frameObj["height"] as? Double ?? 0
            frame = CGRect(x: x, y: y, width: width, height: height)
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.manager.createWebview(
                    id: id,
                    url: url,
                    frame: frame,
                    autoFocus: autoFocus,
                    enableJavaScript: enableJavaScript,
                    allowFileAccess: allowFileAccess,
                    userAgent: userAgent
                )

                self.notifyListeners("webviewCreated", data: ["id": id])
                call.resolve()
            } catch {
                call.reject("Failed to create webview: \(error.localizedDescription)")
            }
        }
    }

    @objc func setFocusedWebview(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.manager.setFocusedWebview(id: id)
                self.notifyListeners("webviewFocused", data: ["id": id])
                call.resolve()
            } catch {
                call.reject("Failed to focus webview: \(error.localizedDescription)")
            }
        }
    }

    @objc func getFocusedWebview(_ call: CAPPluginCall) {
        let focusedId = manager.getFocusedWebviewId()
        call.resolve(["id": focusedId as Any])
    }

    @objc func hideWebview(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.manager.hideWebview(id: id)
                call.resolve()
            } catch {
                call.reject("Failed to hide webview: \(error.localizedDescription)")
            }
        }
    }

    @objc func showWebview(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.manager.showWebview(id: id)
                call.resolve()
            } catch {
                call.reject("Failed to show webview: \(error.localizedDescription)")
            }
        }
    }

    @objc func destroyWebview(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.manager.destroyWebview(id: id)
                self.notifyListeners("webviewDestroyed", data: ["id": id])
                call.resolve()
            } catch {
                call.reject("Failed to destroy webview: \(error.localizedDescription)")
            }
        }
    }

    @objc func loadUrl(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        guard let urlString = call.getString("url") else {
            call.reject("Must provide url")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.manager.loadUrl(id: id, urlString: urlString)
                call.resolve()
            } catch {
                call.reject("Failed to load URL: \(error.localizedDescription)")
            }
        }
    }

    @objc func listWebviews(_ call: CAPPluginCall) {
        let webviews = manager.listWebviews()
        call.resolve(["webviews": webviews])
    }

    @objc func getWebviewInfo(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        do {
            let info = try manager.getWebviewInfo(id: id)
            call.resolve(info)
        } catch {
            call.reject("Failed to get webview info: \(error.localizedDescription)")
        }
    }

    @objc func getAllWebviews(_ call: CAPPluginCall) {
        let webviews = manager.getAllWebviews()
        call.resolve(["webviews": webviews])
    }

    @objc func getWebviewsByUrl(_ call: CAPPluginCall) {
        guard let urlString = call.getString("url") else {
            call.reject("Must provide url")
            return
        }

        let exactMatch = call.getBool("exactMatch") ?? false
        let webviews = manager.getWebviewsByUrl(urlString: urlString, exactMatch: exactMatch)
        call.resolve(["webviews": webviews])
    }

    @objc func setWebviewFrame(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        guard let frameObj = call.getObject("frame") else {
            call.reject("Must provide frame")
            return
        }

        let x = frameObj["x"] as? Double ?? 0
        let y = frameObj["y"] as? Double ?? 0
        let width = frameObj["width"] as? Double ?? 0
        let height = frameObj["height"] as? Double ?? 0
        let frame = CGRect(x: x, y: y, width: width, height: height)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.manager.setWebviewFrame(id: id, frame: frame)
                call.resolve()
            } catch {
                call.reject("Failed to set webview frame: \(error.localizedDescription)")
            }
        }
    }

    @objc func executeJavaScript(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        guard let code = call.getString("code") else {
            call.reject("Must provide code to execute")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            self.manager.executeJavaScript(id: id, code: code) { result, error in
                if let error = error {
                    call.reject("Failed to execute JavaScript: \(error.localizedDescription)")
                } else {
                    var resultString: String?
                    if let result = result {
                        if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: []),
                           let jsonString = String(data: jsonData, encoding: .utf8) {
                            resultString = jsonString
                        } else {
                            resultString = "\(result)"
                        }
                    }
                    call.resolve(["result": resultString as Any])
                }
            }
        }
    }

    @objc func sendMessage(_ call: CAPPluginCall) {
        guard let id = call.getString("id") else {
            call.reject("Must provide webview id")
            return
        }

        guard let data = call.getValue("data") else {
            call.reject("Must provide data")
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            do {
                try self.manager.sendMessage(id: id, data: data)
                call.resolve()
            } catch {
                call.reject("Failed to send message: \(error.localizedDescription)")
            }
        }
    }
}
