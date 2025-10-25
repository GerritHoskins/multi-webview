# Tealium Tag Management Integration with Multi-Webview Plugin

This document describes how to integrate the Tealium Tag Management webview with the Multi-Webview plugin for centralized webview management **without modifying any Tealium source files**.

## Overview

The Tealium Tag Management system uses a WKWebView to load and execute tag management scripts (typically `mobile.html`). This integration allows you to manage and control the Tealium webview through the Multi-Webview plugin API alongside your other webviews.

**Key Features:**
- ✅ **Non-invasive** - No modifications to Tealium source code
- ✅ **Uses Tealium's public API** - Integrates via `getWebView()` method
- ✅ **Explicit control** - You decide when to integrate
- ✅ **Fully compatible** - Works with standard Tealium updates

## Integration Methods

There are two ways to integrate Tealium with the Multi-Webview plugin:

### Method 1: Using Tealium Module (Recommended)

If you have access to the Tealium module instance:

```swift
import Capacitor

// In your app code, after Tealium is initialized
class MyViewController: UIViewController {

    func setupTealiumIntegration() {
        // Get your multi-webview plugin instance
        guard let plugin = bridge?.getPlugin(withName: "MsAppMultiWebview") as? MsAppMultiWebviewPlugin else {
            return
        }

        // Get your Tealium tag management module
        // (Assuming you have access to it via your Tealium instance)
        if let tagManagement = tealium.modules.first(where: { $0.id == "tagmanagement" }) {
            // Integrate using Tealium's getWebView() API
            TealiumMultiWebviewIntegration.shared.integrateWith(
                tealiumModule: tagManagement,
                manager: plugin.manager,
                plugin: plugin
            ) { success in
                if success {
                    print("✅ Tealium webview integrated with Multi-Webview plugin")
                } else {
                    print("❌ Failed to integrate Tealium webview")
                }
            }
        }
    }
}
```

### Method 2: Direct Webview Registration

If you have direct access to the Tealium WKWebView instance:

```swift
// Assuming you obtained the webview from Tealium somehow
let tealiumWebview: WKWebView = // ... your Tealium webview

TealiumMultiWebviewIntegration.shared.registerWebview(
    tealiumWebview,
    manager: plugin.manager,
    plugin: plugin,
    url: "https://tags.tiqcdn.com/utag/your-account/your-profile/mobile.html"
)
```

## Complete Setup Example

Here's a complete example of setting up Tealium integration in a Capacitor app:

```swift
import Capacitor
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tealium: Tealium?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize Tealium
        setupTealium()

        // Wait for bridge to be ready, then integrate
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bridgeDidLoad),
            name: .capacitorBridgeDidLoad,
            object: nil
        )

        return true
    }

    func setupTealium() {
        let config = TealiumConfig(account: "your-account",
                                   profile: "your-profile",
                                   environment: "prod")

        // Enable tag management module
        config.dispatchers = [Dispatchers.TagManagement]

        tealium = Tealium(config: config) { [weak self] _ in
            print("Tealium initialized")
            self?.integrateTealiumIfReady()
        }
    }

    @objc func bridgeDidLoad(_ notification: Notification) {
        integrateTealiumIfReady()
    }

    func integrateTealiumIfReady() {
        guard let bridge = (window?.rootViewController as? CAPBridgeViewController)?.bridge,
              let plugin = bridge.getPlugin(withName: "MsAppMultiWebview") as? MsAppMultiWebviewPlugin,
              let tealium = tealium else {
            return
        }

        // Get the tag management module
        guard let tagManagementModule = tealium.modules.first(where: { $0.id == "tagmanagement" }) else {
            return
        }

        // Integrate Tealium webview with Multi-Webview plugin
        TealiumMultiWebviewIntegration.shared.integrateWith(
            tealiumModule: tagManagementModule,
            manager: plugin.manager,
            plugin: plugin
        ) { success in
            if success {
                print("✅ Tealium integrated with Multi-Webview")
            }
        }
    }
}
```

## Using the Integration from JavaScript/TypeScript

Once integrated, you can control the Tealium webview using the standard Multi-Webview plugin API:

```typescript
import { MsAppMultiWebview } from '@ms-app/multi-webview';

// Reserved ID for Tealium webview
const TEALIUM_ID = 'tealium-tag-manager';

// Get information about the Tealium webview
const info = await MsAppMultiWebview.getWebviewInfo({ id: TEALIUM_ID });
console.log('Tealium webview:', info);
// { id: 'tealium-tag-manager', url: 'https://tags.tiqcdn.com/...', isHidden: false, isFocused: false }

// Hide the Tealium webview
await MsAppMultiWebview.hideWebview({ id: TEALIUM_ID });

// Show the Tealium webview
await MsAppMultiWebview.showWebview({ id: TEALIUM_ID });

// Set frame/position for debugging
await MsAppMultiWebview.setWebviewFrame({
  id: TEALIUM_ID,
  frame: {
    x: 0,
    y: 0,
    width: window.innerWidth,
    height: 300
  }
});

// Execute JavaScript in Tealium context
const result = await MsAppMultiWebview.executeJavaScript({
  id: TEALIUM_ID,
  code: 'JSON.stringify(window.utag.data)'
});
console.log('Tealium utag.data:', JSON.parse(result.result));

// List all webviews (including Tealium)
const { webviews } = await MsAppMultiWebview.listWebviews();
console.log('All webviews:', webviews);
// ['tealium-tag-manager', 'my-webview-1', 'my-webview-2']

// Check if Tealium webview is in the list
const hasTealium = webviews.includes(TEALIUM_ID);
console.log('Tealium integrated:', hasTealium);
```

## What You Can Do

With the Multi-Webview plugin, you can:

✅ **Get webview information** - Check URL, visibility, and focus state
✅ **Show/Hide** - Control visibility of the Tealium webview
✅ **Set Frame** - Position and resize the webview
✅ **Execute JavaScript** - Run custom scripts in the Tealium webview context
✅ **List webviews** - Enumerate all managed webviews including Tealium
✅ **Focus control** - Bring Tealium webview to front or send it to back

## What You Cannot Do

The following operations are **not supported** for the Tealium webview:

❌ **Destroy** - The Tealium webview lifecycle is managed by Tealium
❌ **Load URL** - URL loading is controlled by Tealium's tag management system
❌ **Create** - The webview is created by Tealium, not the plugin

Attempting these operations may result in errors or conflicts with Tealium's lifecycle management.

## Advanced Usage

### Detecting Integration Status

```swift
// Check if Tealium is integrated
let isIntegrated = TealiumMultiWebviewIntegration.shared.isIntegratedWithMultiWebview()
print("Tealium integrated:", isIntegrated)

// Get the Tealium webview ID
let tealiumId = TealiumMultiWebviewIntegration.getTealiumWebviewId()
print("Tealium ID:", tealiumId) // "tealium-tag-manager"
```

### Unregistering Tealium

If you need to stop managing the Tealium webview:

```swift
// Unregister Tealium from Multi-Webview management
TealiumMultiWebviewIntegration.shared.unregister()
```

### Handling Tealium Lifecycle

```swift
// When Tealium is disabled/destroyed
func cleanupTealium() {
    // First unregister from Multi-Webview
    TealiumMultiWebviewIntegration.shared.unregister()

    // Then disable Tealium
    tealium?.disable()
}
```

## Use Cases

### 1. Debugging Tealium in Development

Show the Tealium webview during development to debug tag firing:

```typescript
if (process.env.NODE_ENV === 'development') {
  // Make Tealium webview visible for debugging
  await MsAppMultiWebview.setWebviewFrame({
    id: 'tealium-tag-manager',
    frame: { x: 0, y: 0, width: window.innerWidth, height: 400 }
  });
  await MsAppMultiWebview.showWebview({ id: 'tealium-tag-manager' });
  await MsAppMultiWebview.setFocusedWebview({ id: 'tealium-tag-manager' });
}
```

### 2. Inspecting Tealium Data Layer

Check what data Tealium has collected:

```typescript
async function inspectTealiumData() {
  try {
    const result = await MsAppMultiWebview.executeJavaScript({
      id: 'tealium-tag-manager',
      code: 'JSON.stringify({ data: window.utag.data, version: window.utag.cfg.v })'
    });

    const tealiumInfo = JSON.parse(result.result);
    console.log('Tealium Data:', tealiumInfo.data);
    console.log('Tealium Version:', tealiumInfo.version);
  } catch (error) {
    console.error('Failed to inspect Tealium:', error);
  }
}
```

### 3. Conditional Display Based on User Role

Show Tealium debugger to QA users:

```typescript
async function setupTealiumDebugger(userRole: string) {
  if (userRole === 'qa' || userRole === 'admin') {
    const info = await MsAppMultiWebview.getWebviewInfo({ id: 'tealium-tag-manager' });

    if (info.isHidden) {
      await MsAppMultiWebview.showWebview({ id: 'tealium-tag-manager' });
      await MsAppMultiWebview.setWebviewFrame({
        id: 'tealium-tag-manager',
        frame: { x: 0, y: 600, width: window.innerWidth, height: 200 }
      });
    }
  }
}
```

### 4. Monitoring Tag Execution

Execute custom monitoring code:

```typescript
async function monitorTealiumTags() {
  await MsAppMultiWebview.executeJavaScript({
    id: 'tealium-tag-manager',
    code: `
      if (!window.tealiumMonitor) {
        window.tealiumMonitor = true;
        window.utag.DB = console.log.bind(console);
        console.log('Tealium tag monitoring enabled');
      }
    `
  });
}
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Capacitor App                        │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │     Multi-Webview Plugin (JavaScript)              │     │
│  │  MsAppMultiWebview.getWebviewInfo({ id: '...' })  │     │
│  └─────────────────────┬──────────────────────────────┘     │
│                        │ Capacitor Bridge                    │
└────────────────────────┼─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│                    Native iOS Layer                          │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │      MsAppMultiWebviewPlugin                     │       │
│  │  ┌────────────────────────────────────────┐     │       │
│  │  │   MsAppMultiWebviewManager             │     │       │
│  │  │   webviews: [String: WebviewContainer] │     │       │
│  │  │     ['tealium-tag-manager': ...]       │     │       │
│  │  └────────────────────────────────────────┘     │       │
│  └──────────────────┬───────────────────────────────┘       │
│                     │                                        │
│  ┌──────────────────▼──────────────────────────────┐        │
│  │  TealiumMultiWebviewIntegration                 │        │
│  │  (Non-invasive bridge - no Tealium edits)      │        │
│  │                                                  │        │
│  │  • integrateWith(tealiumModule:...)            │        │
│  │  • registerWebview(_:...)                       │        │
│  │  • Uses getWebView() API                        │        │
│  └──────────────────┬──────────────────────────────┘        │
│                     │ Uses Public API                        │
│                     │ (getWebView)                          │
│  ┌──────────────────▼──────────────────────────────┐        │
│  │    Tealium Tag Management (Unmodified)          │        │
│  │                                                  │        │
│  │  ┌────────────────────────────────────┐         │        │
│  │  │  TagManagementWKWebView            │         │        │
│  │  │  • webview: WKWebView              │         │        │
│  │  │  • getWebView(_ completion:)       │ ◄───────┼────────┐
│  │  │  • track()                          │         │         │
│  │  │  • url: URL?                        │         │         │
│  │  └────────────────────────────────────┘         │         │
│  └──────────────────────────────────────────────────┘         │
│                                                                │
│  No modifications to Tealium source code required!            │
└───────────────────────────────────────────────────────────────┘
```

## API Reference

### TealiumMultiWebviewIntegration

#### Class Properties

- `static let tealiumWebviewId: String` - Reserved ID: `"tealium-tag-manager"`
- `static let shared: TealiumMultiWebviewIntegration` - Singleton instance

#### Methods

##### `integrateWith(tealiumModule:manager:plugin:completion:)`

Integrate Tealium webview using Tealium's module API.

**Parameters:**
- `tealiumModule: Any` - The Tealium tag management module instance
- `manager: MsAppMultiWebviewManager` - The multi-webview manager
- `plugin: CAPPlugin` - The plugin instance for notifications
- `completion: ((Bool) -> Void)?` - Optional completion handler

##### `registerWebview(_:manager:plugin:url:)`

Manually register a Tealium webview.

**Parameters:**
- `webview: WKWebView` - The Tealium WKWebView instance
- `manager: MsAppMultiWebviewManager` - The multi-webview manager
- `plugin: CAPPlugin` - The plugin instance
- `url: String?` - Optional URL

**Returns:** `Bool` indicating success

##### `unregister()`

Unregister Tealium webview from multi-webview management.

##### `isIntegratedWithMultiWebview() -> Bool`

Check if Tealium is currently integrated.

##### `static getTealiumWebviewId() -> String`

Get the reserved Tealium webview ID.

## Troubleshooting

### Integration doesn't work

**Problem:** `integrateWith` returns `false` or never completes

**Solutions:**
- Ensure Tealium is fully initialized before integrating
- Verify the tag management module is enabled in Tealium config
- Check that the multi-webview plugin is loaded
- Confirm Tealium's webview has been created (may take time after init)

### Webview not found

**Problem:** `getWebviewInfo` fails with "webview not found"

**Solutions:**
- Call integration after both Tealium and Capacitor bridge are ready
- Use `listWebviews()` to verify integration succeeded
- Check `isIntegratedWithMultiWebview()` status

### JavaScript execution fails

**Problem:** `executeJavaScript()` returns errors

**Solutions:**
- Wait for Tealium's webview to fully load before executing
- Verify the JavaScript code is valid
- Check that accessed objects exist in Tealium's context
- Ensure Tealium hasn't been disabled

## Best Practices

1. **Integrate after initialization** - Wait for both Tealium and Capacitor to be ready
2. **Use observers** - Listen for Capacitor bridge load events
3. **Check integration status** - Verify `isIntegratedWithMultiWebview()` before operations
4. **Don't interfere with Tealium lifecycle** - Let Tealium manage creation/destruction
5. **Use for visibility/debugging** - Best for controlling when/where webview appears
6. **Keep Tealium updated** - No source modifications means easy upgrades!

## Benefits of Non-Invasive Integration

✅ **Maintainable** - No merge conflicts when updating Tealium
✅ **Safe** - Tealium's code remains untouched
✅ **Flexible** - Choose when and how to integrate
✅ **Upgradeable** - Compatible with Tealium updates
✅ **Debuggable** - Integration code is separate and clear

## License

This integration helper is part of the Multi-Webview plugin and follows the same license.
