# Multi-Webview Plugin Integration Helpers

This directory contains integration helper files for using the Multi-Webview plugin with third-party libraries.

## Tealium Tag Management Integration (iOS)

### Overview

The `ios/TealiumMultiWebviewIntegration.swift` file enables you to manage the Tealium Tag Management webview through the Multi-Webview plugin API.

### Installation

1. **Copy the integration file to your iOS app project:**
   ```
   integration-helpers/ios/TealiumMultiWebviewIntegration.swift
   → YourApp/App/App/TealiumMultiWebviewIntegration.swift
   ```

2. **Add to your app target** (NOT the Capacitor plugin target)
   - In Xcode: Right-click your app group → Add Files
   - Select `TealiumMultiWebviewIntegration.swift`
   - Ensure it's added to your app target

### Usage

After both Tealium and Capacitor are initialized:

```swift
import UIKit
import Capacitor

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tealiumWebview: WKWebView?  // Store reference

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize Tealium (your existing code)
        setupTealium()

        return true
    }

    func setupTealium() {
        // Your Tealium initialization...
        // Get the webview from Tealium somehow and store it
        // Example (depends on your Tealium setup):
        tealiumWebview = getTealiumWebviewSomehow()

        // Wait for Capacitor bridge to be ready
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(integrateTealium),
            name: .capacitorBridgeDidLoad,
            object: nil
        )
    }

    @objc func integrateTealium(_ notification: Notification) {
        guard let bridge = (window?.rootViewController as? CAPBridgeViewController)?.bridge,
              let tealiumWV = tealiumWebview else {
            return
        }

        // Integrate Tealium webview with Multi-Webview plugin
        let success = TealiumMultiWebviewBridge.integrate(
            tealiumWebview: tealiumWV,
            tealiumURL: "https://tags.tiqcdn.com/utag/your-account/your-profile/mobile.html",
            bridge: bridge
        )

        if success {
            print("✅ Tealium integrated with Multi-Webview plugin")
            print("   Use webview ID 'tealium-tag-manager' in JavaScript")
        }
    }
}
```

### Control from JavaScript/TypeScript

Once integrated, control the Tealium webview from your web code:

```typescript
import { MsAppMultiWebview } from '@ms-app/multi-webview';

const TEALIUM_ID = 'tealium-tag-manager';

// Get webview info
const info = await MsAppMultiWebview.getWebviewInfo({ id: TEALIUM_ID });
console.log('Tealium URL:', info.url);

// Show/hide for debugging
await MsAppMultiWebview.showWebview({ id: TEALIUM_ID });
await MsAppMultiWebview.setWebviewFrame({
  id: TEALIUM_ID,
  frame: { x: 0, y: 0, width: 400, height: 300 }
});

// Execute JavaScript in Tealium context
const result = await MsAppMultiWebview.executeJavaScript({
  id: TEALIUM_ID,
  code: 'JSON.stringify(window.utag.data)'
});
console.log('Tealium data:', JSON.parse(result.result));

// List all webviews (includes Tealium)
const { webviews } = await MsAppMultiWebview.listWebviews();
console.log('All webviews:', webviews);
// Output: ['tealium-tag-manager', 'my-webview-1', ...]
```

### Getting the Tealium Webview

How you get the Tealium WKWebView depends on your Tealium integration. Here are some approaches:

#### Option 1: Using Tealium's getWebView() API

```swift
// If you have access to the tag management module
if let tagManagement = tealium.tagManagement {
    tagManagement.getWebView { webview in
        self.tealiumWebview = webview
        // Now integrate when bridge is ready
    }
}
```

#### Option 2: Direct Access

```swift
// If you can access it directly
if let webview = tealium.tagManagement?.webview {
    self.tealiumWebview = webview
}
```

#### Option 3: Swizzling/Notification

```swift
// Set up notification when Tealium creates its webview
// (Implementation depends on your Tealium version)
```

### API Reference

#### `TealiumMultiWebviewBridge.integrate()`

Integrates the Tealium webview with Multi-Webview plugin.

**Parameters:**
- `tealiumWebview: WKWebView` - The webview from Tealium
- `tealiumURL: String?` - Optional URL of the webview
- `bridge: CAPBridgeProtocol` - Your Capacitor bridge

**Returns:** `Bool` - True if successful

#### `TealiumMultiWebviewBridge.unregister()`

Removes Tealium webview from Multi-Webview management.

**Parameters:**
- `bridge: CAPBridgeProtocol` - Your Capacitor bridge

#### `TealiumMultiWebviewBridge.tealiumWebviewId`

Static property containing the reserved webview ID: `"tealium-tag-manager"`

Use this ID in all JavaScript calls to the Multi-Webview plugin.

### Features

Once integrated, you can:

✅ Show/hide the Tealium webview
✅ Set frame and position
✅ Execute JavaScript in Tealium context
✅ Get webview information
✅ List all webviews (including Tealium)
✅ Focus management

### Troubleshooting

**"Multi-Webview plugin not found"**
- Ensure the plugin is installed and loaded
- Check that you're calling integrate after Capacitor bridge is ready

**"registerExternalWebview method not available"**
- Make sure you're using the latest version of the Multi-Webview plugin
- The plugin must include the external webview registration feature

**Can't get Tealium webview**
- Check your Tealium initialization code
- Ensure tag management module is enabled
- Try using Tealium's `getWebView()` callback method

**Integration returns false**
- Check console logs for specific error messages
- Verify both Tealium and Capacitor are fully initialized
- Ensure the webview exists before calling integrate()

### Complete Example

See `TEALIUM_INTEGRATION.md` in the root directory for a complete integration guide with detailed examples.

## Future Integrations

This directory will contain integration helpers for other third-party libraries that use webviews, such as:

- Google Tag Manager
- Adobe Analytics
- Custom webview libraries

If you've created an integration for another library, please consider contributing it!

## License

These integration helpers are part of the Multi-Webview plugin and follow the same license.
