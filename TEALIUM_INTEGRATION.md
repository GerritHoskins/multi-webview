# Tealium Tag Management Integration with Multi-Webview Plugin

This document describes how the Tealium Tag Management webview is integrated with the Multi-Webview plugin for centralized webview management.

## Overview

The Tealium Tag Management system uses a WKWebView to load and execute tag management scripts (typically `mobile.html`). This integration allows you to manage and control the Tealium webview through the Multi-Webview plugin API alongside your other webviews.

## How It Works

### Automatic Registration

When Tealium Tag Management initializes its webview, it automatically registers with the Multi-Webview plugin using a reserved webview ID: `tealium-tag-manager`.

The registration happens in the `TagManagementWKWebView.setupWebview()` method when:
1. The WKWebView is created
2. Before the webview is attached to the view hierarchy
3. Before loading the tag management URL

### Reserved Webview ID

The Tealium webview is always registered with the ID: **`tealium-tag-manager`**

This is a reserved ID that should not be used for any other webviews in your application.

## Using the Integration

### JavaScript/TypeScript API

You can control the Tealium webview using the standard Multi-Webview plugin API:

```typescript
import { MsAppMultiWebview } from '@ms-app/multi-webview';

const TEALIUM_ID = 'tealium-tag-manager';

// Get information about the Tealium webview
const info = await MsAppMultiWebview.getWebviewInfo({ id: TEALIUM_ID });
console.log('Tealium webview URL:', info.url);
console.log('Is hidden:', info.isHidden);
console.log('Is focused:', info.isFocused);

// Hide the Tealium webview
await MsAppMultiWebview.hideWebview({ id: TEALIUM_ID });

// Show the Tealium webview
await MsAppMultiWebview.showWebview({ id: TEALIUM_ID });

// Set the frame/position of the Tealium webview
await MsAppMultiWebview.setWebviewFrame({
  id: TEALIUM_ID,
  frame: {
    x: 0,
    y: 0,
    width: 300,
    height: 200
  }
});

// Execute custom JavaScript in the Tealium webview
const result = await MsAppMultiWebview.executeJavaScript({
  id: TEALIUM_ID,
  code: 'window.utag.data'
});
console.log('Tealium data:', result.result);

// List all webviews (including Tealium)
const { webviews } = await MsAppMultiWebview.listWebviews();
console.log('All webviews:', webviews);
// Output: ['tealium-tag-manager', 'my-webview-1', 'my-webview-2']

// Get all webviews with details
const { webviews: allWebviews } = await MsAppMultiWebview.getAllWebviews();
const tealiumWebview = allWebviews.find(w => w.id === TEALIUM_ID);
```

### What You Can Do

With the Multi-Webview plugin, you can:

1. **Get webview information** - Check URL, visibility, and focus state
2. **Show/Hide** - Control visibility of the Tealium webview
3. **Set Frame** - Position and resize the webview
4. **Execute JavaScript** - Run custom scripts in the Tealium webview context
5. **List webviews** - Enumerate all managed webviews including Tealium
6. **Focus control** - Bring Tealium webview to front or send it to back

### What You Cannot Do

The following operations are **not supported** for the Tealium webview:

1. **Destroy** - The Tealium webview lifecycle is managed by Tealium, not the plugin
2. **Load URL** - URL loading is controlled by Tealium's tag management system
3. **Create** - The webview is automatically created by Tealium
4. **Send Messages** - Use Tealium's native messaging system instead

Attempting these operations on the `tealium-tag-manager` webview may result in errors or undefined behavior.

## iOS Implementation Details

### TealiumMultiWebviewIntegration

The `TealiumMultiWebviewIntegration` class acts as a bridge between Tealium and the Multi-Webview plugin:

```swift
// Get the Tealium webview ID
let tealiumId = TealiumMultiWebviewIntegration.getTealiumWebviewId()

// Check if Tealium webview is registered
let isRegistered = TealiumMultiWebviewIntegration.shared.isTealiumWebviewRegistered()
```

### MsAppMultiWebviewManager Extensions

The manager has been extended to support external webview registration:

```swift
// Register an externally created webview
try manager.registerExternalWebview(
    id: "my-external-webview",
    webview: myWKWebView,
    url: "https://example.com"
)

// Update webview URL
try manager.updateWebviewUrl(id: "my-external-webview", url: "https://new-url.com")

// Check if webview exists
let exists = manager.webviewExists(id: "my-external-webview")
```

## Lifecycle

### Initialization

1. Tealium Tag Management module initializes
2. `TagManagementWKWebView.setupWebview()` is called
3. WKWebView is created with Tealium configuration
4. Webview is registered with Multi-Webview plugin as `tealium-tag-manager`
5. Webview is attached to view hierarchy
6. Tag management URL is loaded

### Cleanup

1. Tealium Tag Management module disables
2. `TagManagementWKWebView.disable()` is called
3. Webview is unregistered from Multi-Webview plugin
4. Webview is removed from view hierarchy
5. Webview is stopped and deallocated

## Best Practices

1. **Don't manually create a webview with ID `tealium-tag-manager`** - This ID is reserved
2. **Use Tealium's API for tracking** - Don't bypass Tealium's track methods
3. **Check registration status** - Before attempting to control the Tealium webview, verify it's registered
4. **Respect Tealium's lifecycle** - Don't destroy or recreate the Tealium webview manually
5. **Use for visibility/layout control** - The integration is best for controlling when and where the Tealium webview appears

## Example Use Case

### Debugging Tealium in Development

```typescript
// Show Tealium webview for debugging
if (isDevelopment) {
  await MsAppMultiWebview.setWebviewFrame({
    id: 'tealium-tag-manager',
    frame: { x: 0, y: 0, width: window.innerWidth, height: 400 }
  });
  await MsAppMultiWebview.showWebview({ id: 'tealium-tag-manager' });
  await MsAppMultiWebview.setFocusedWebview({ id: 'tealium-tag-manager' });
}
```

### Inspecting Tealium Data

```typescript
// Get current utag data
const result = await MsAppMultiWebview.executeJavaScript({
  id: 'tealium-tag-manager',
  code: 'JSON.stringify(window.utag.data)'
});

console.log('Current Tealium data:', JSON.parse(result.result));
```

### Conditional Display

```typescript
// Show Tealium webview only when needed
async function showTealiumDebugger() {
  const info = await MsAppMultiWebview.getWebviewInfo({ id: 'tealium-tag-manager' });

  if (info.isHidden) {
    await MsAppMultiWebview.showWebview({ id: 'tealium-tag-manager' });
    await MsAppMultiWebview.setWebviewFrame({
      id: 'tealium-tag-manager',
      frame: { x: 0, y: 600, width: window.innerWidth, height: 200 }
    });
  }
}
```

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Your Capacitor App                        │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │        Multi-Webview Plugin (JavaScript)           │     │
│  │                                                     │     │
│  │  - createWebview()                                 │     │
│  │  - getWebviewInfo({ id: 'tealium-tag-manager' })  │     │
│  │  - hideWebview({ id: 'tealium-tag-manager' })     │     │
│  │  - executeJavaScript(...)                          │     │
│  └─────────────────────┬──────────────────────────────┘     │
│                        │                                     │
└────────────────────────┼─────────────────────────────────────┘
                         │ Bridge
┌────────────────────────▼─────────────────────────────────────┐
│                    Native iOS Layer                          │
│                                                              │
│  ┌──────────────────────────────────────────────────┐       │
│  │      MsAppMultiWebviewPlugin                     │       │
│  │                                                   │       │
│  │  ┌─────────────────────────────────────────┐    │       │
│  │  │    MsAppMultiWebviewManager             │    │       │
│  │  │                                          │    │       │
│  │  │  - Manages all WKWebViews               │    │       │
│  │  │  - webviews: [String: WebviewContainer] │    │       │
│  │  │    ['tealium-tag-manager': Container]   │    │       │
│  │  │    ['my-webview-1': Container]          │    │       │
│  │  └───────────────┬──────────────────────────┘    │       │
│  └──────────────────┼───────────────────────────────┘       │
│                     │                                        │
│  ┌──────────────────▼──────────────────────────────┐        │
│  │  TealiumMultiWebviewIntegration (Bridge)        │        │
│  │                                                  │        │
│  │  - registerTealiumWebview()                     │        │
│  │  - unregisterTealiumWebview()                   │        │
│  │  - Coordinates between systems                  │        │
│  └──────────────────┬──────────────────────────────┘        │
│                     │                                        │
│  ┌──────────────────▼──────────────────────────────┐        │
│  │    Tealium Tag Management                       │        │
│  │                                                  │        │
│  │  ┌────────────────────────────────────┐         │        │
│  │  │  TagManagementWKWebView            │         │        │
│  │  │                                     │         │        │
│  │  │  - webview: WKWebView              │         │        │
│  │  │  - track()                          │         │        │
│  │  │  - evaluateJavascript()            │         │        │
│  │  └────────────────────────────────────┘         │        │
│  └──────────────────────────────────────────────────┘        │
└───────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Tealium webview not found

If you get an error that the `tealium-tag-manager` webview doesn't exist:
- Ensure Tealium Tag Management has been initialized
- Check that the CAPACITOR flag is defined during compilation
- Verify the integration files are included in your build

### Cannot control Tealium webview

If show/hide/frame operations don't work:
- Verify the webview is registered: `MsAppMultiWebview.listWebviews()`
- Check that operations are performed on the main thread (iOS)
- Ensure Tealium hasn't disabled or removed the webview

### JavaScript execution fails

If `executeJavaScript()` returns errors:
- Verify the Tealium webview has finished loading
- Check that the JavaScript code is valid
- Ensure you're accessing objects that exist in the Tealium webview context

## Support

For issues specific to:
- **Multi-Webview Plugin**: Check the main README.md
- **Tealium Tag Management**: Refer to Tealium's documentation
- **Integration**: Review this document and the source code in `TealiumMultiWebviewIntegration.swift`
