# Tealium Tag Management Integration with Multi-Webview Plugin

This document describes how to integrate the Tealium Tag Management webview with the Multi-Webview plugin for centralized webview management **without modifying any Tealium source files**.

## Overview

The Tealium Tag Management system uses a WKWebView to load and execute tag management scripts (typically `mobile.html`). This integration allows you to manage and control the Tealium webview through the Multi-Webview plugin API alongside your other webviews.

**Key Features:**
- ✅ **Non-invasive** - No modifications to Tealium source code
- ✅ **Simple integration** - Just copy one file to your iOS app project
- ✅ **Explicit control** - You decide when to integrate
- ✅ **Fully compatible** - Works with standard Tealium updates

## Quick Start

### Step 1: Add Integration Helper

Copy the integration helper file to your iOS app project:

```
multi-webview/integration-helpers/ios/TealiumMultiWebviewIntegration.swift
→ YourApp/App/App/TealiumMultiWebviewIntegration.swift
```

**Important:** Add it to your **app target**, not the Capacitor plugin target.

### Step 2: Integrate in iOS Code

```swift
import UIKit
import Capacitor

class AppDelegate: UIResponder, UIApplicationDelegate {

    var tealiumWebview: WKWebView?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        setupTealium()

        // Wait for Capacitor bridge
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(integrateTealium),
            name: .capacitorBridgeDidLoad,
            object: nil
        )

        return true
    }

    func setupTealium() {
        // Your Tealium initialization...
        // Store webview reference from Tealium
    }

    @objc func integrateTealium(_ notification: Notification) {
        guard let bridge = (window?.rootViewController as? CAPBridgeViewController)?.bridge,
              let webview = tealiumWebview else {
            return
        }

        TealiumMultiWebviewBridge.integrate(
            tealiumWebview: webview,
            tealiumURL: "https://tags.tiqcdn.com/utag/account/profile/mobile.html",
            bridge: bridge
        )
    }
}
```

### Step 3: Control from JavaScript

```typescript
import { MsAppMultiWebview } from '@ms-app/multi-webview';

const TEALIUM_ID = 'tealium-tag-manager';

// Show for debugging
await MsAppMultiWebview.showWebview({ id: TEALIUM_ID });
await MsAppMultiWebview.setWebviewFrame({
  id: TEALIUM_ID,
  frame: { x: 0, y: 0, width: 400, height: 300 }
});

// Execute JavaScript
const result = await MsAppMultiWebview.executeJavaScript({
  id: TEALIUM_ID,
  code: 'JSON.stringify(window.utag.data)'
});
```

For complete documentation, see `integration-helpers/README.md`.

## Reserved Webview ID

The Tealium webview is always registered with ID: **`"tealium-tag-manager"`**

Use this ID in all JavaScript calls to the Multi-Webview plugin.

## What You Can Do

✅ Show/hide the Tealium webview
✅ Set frame and position
✅ Execute JavaScript in Tealium context
✅ Get webview information
✅ List all webviews (including Tealium)
✅ Focus management

## What's Tealium-Managed

❌ Webview creation/destruction (handled by Tealium)
❌ URL loading (handled by Tealium's tag management)
❌ Tracking lifecycle (use Tealium's track methods)

## Complete Documentation

See `integration-helpers/README.md` for:
- Detailed setup instructions
- Complete code examples
- API reference
- Troubleshooting guide
- Use cases and best practices
