# @gerrithoskins/multi-webview

Capacitor plugin for managing multiple web views with programmatic focus control.

## Install

```bash
npm install @gerrithoskins/multi-webview
npx cap sync
```

## API

<docgen-index>

* [`createWebview(...)`](#createwebview)
* [`setFocusedWebview(...)`](#setfocusedwebview)
* [`getFocusedWebview()`](#getfocusedwebview)
* [`hideWebview(...)`](#hidewebview)
* [`showWebview(...)`](#showwebview)
* [`destroyWebview(...)`](#destroywebview)
* [`loadUrl(...)`](#loadurl)
* [`listWebviews()`](#listwebviews)
* [`getWebviewInfo(...)`](#getwebviewinfo)
* [`getAllWebviews()`](#getallwebviews)
* [`getWebviewsByUrl(...)`](#getwebviewsbyurl)
* [`setWebviewFrame(...)`](#setwebviewframe)
* [`executeJavaScript(...)`](#executejavascript)
* [`sendMessage(...)`](#sendmessage)
* [`addListener('message', ...)`](#addlistenermessage-)
* [`addListener('webviewCreated' | 'webviewDestroyed' | 'webviewFocused', ...)`](#addlistenerwebviewcreated--webviewdestroyed--webviewfocused-)
* [`addListener('loadStart' | 'loadFinish' | 'loadError', ...)`](#addlistenerloadstart--loadfinish--loaderror-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### createWebview(...)

```typescript
createWebview(options: CreateWebviewOptions) => Promise<void>
```

Create a new webview with the specified identifier and configuration.

| Param         | Type                                                                  | Description                            |
| ------------- | --------------------------------------------------------------------- | -------------------------------------- |
| **`options`** | <code><a href="#createwebviewoptions">CreateWebviewOptions</a></code> | Configuration for creating the webview |

**Since:** 1.0.0

--------------------


### setFocusedWebview(...)

```typescript
setFocusedWebview(options: SetFocusedWebviewOptions) => Promise<void>
```

Bring the specified webview to the foreground and give it focus.

| Param         | Type                                                                          | Description                               |
| ------------- | ----------------------------------------------------------------------------- | ----------------------------------------- |
| **`options`** | <code><a href="#setfocusedwebviewoptions">SetFocusedWebviewOptions</a></code> | Options specifying which webview to focus |

**Since:** 1.0.0

--------------------


### getFocusedWebview()

```typescript
getFocusedWebview() => Promise<FocusedWebviewResult>
```

Get the identifier of the currently focused webview.

**Returns:** <code>Promise&lt;<a href="#focusedwebviewresult">FocusedWebviewResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### hideWebview(...)

```typescript
hideWebview(options: WebviewIdentifier) => Promise<void>
```

Hide the specified webview (removes from view but keeps in memory).

| Param         | Type                                                            | Description                              |
| ------------- | --------------------------------------------------------------- | ---------------------------------------- |
| **`options`** | <code><a href="#webviewidentifier">WebviewIdentifier</a></code> | Options specifying which webview to hide |

**Since:** 1.0.0

--------------------


### showWebview(...)

```typescript
showWebview(options: WebviewIdentifier) => Promise<void>
```

Show a previously hidden webview.

| Param         | Type                                                            | Description                              |
| ------------- | --------------------------------------------------------------- | ---------------------------------------- |
| **`options`** | <code><a href="#webviewidentifier">WebviewIdentifier</a></code> | Options specifying which webview to show |

**Since:** 1.0.0

--------------------


### destroyWebview(...)

```typescript
destroyWebview(options: WebviewIdentifier) => Promise<void>
```

Destroy the specified webview and free its resources.

| Param         | Type                                                            | Description                                 |
| ------------- | --------------------------------------------------------------- | ------------------------------------------- |
| **`options`** | <code><a href="#webviewidentifier">WebviewIdentifier</a></code> | Options specifying which webview to destroy |

**Since:** 1.0.0

--------------------


### loadUrl(...)

```typescript
loadUrl(options: LoadUrlOptions) => Promise<void>
```

Load a URL in the specified webview.

| Param         | Type                                                      | Description                                    |
| ------------- | --------------------------------------------------------- | ---------------------------------------------- |
| **`options`** | <code><a href="#loadurloptions">LoadUrlOptions</a></code> | Options specifying the webview and URL to load |

**Since:** 1.0.0

--------------------


### listWebviews()

```typescript
listWebviews() => Promise<ListWebviewsResult>
```

Get a list of all webview identifiers currently managed by the plugin.

**Returns:** <code>Promise&lt;<a href="#listwebviewsresult">ListWebviewsResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### getWebviewInfo(...)

```typescript
getWebviewInfo(options: WebviewIdentifier) => Promise<WebviewInfo>
```

Get detailed information about a specific webview.

| Param         | Type                                                            | Description                                      |
| ------------- | --------------------------------------------------------------- | ------------------------------------------------ |
| **`options`** | <code><a href="#webviewidentifier">WebviewIdentifier</a></code> | Options specifying which webview to get info for |

**Returns:** <code>Promise&lt;<a href="#webviewinfo">WebviewInfo</a>&gt;</code>

**Since:** 1.0.0

--------------------


### getAllWebviews()

```typescript
getAllWebviews() => Promise<AllWebviewsResult>
```

Get detailed information about all webviews.

**Returns:** <code>Promise&lt;<a href="#allwebviewsresult">AllWebviewsResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### getWebviewsByUrl(...)

```typescript
getWebviewsByUrl(options: GetWebviewsByUrlOptions) => Promise<WebviewsByUrlResult>
```

Get webviews that match a specific URL or URL pattern.

| Param         | Type                                                                        | Description                              |
| ------------- | --------------------------------------------------------------------------- | ---------------------------------------- |
| **`options`** | <code><a href="#getwebviewsbyurloptions">GetWebviewsByUrlOptions</a></code> | Options specifying the URL to search for |

**Returns:** <code>Promise&lt;<a href="#webviewsbyurlresult">WebviewsByUrlResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### setWebviewFrame(...)

```typescript
setWebviewFrame(options: SetWebviewFrameOptions) => Promise<void>
```

Set the frame/bounds of the specified webview.

| Param         | Type                                                                      | Description                                      |
| ------------- | ------------------------------------------------------------------------- | ------------------------------------------------ |
| **`options`** | <code><a href="#setwebviewframeoptions">SetWebviewFrameOptions</a></code> | Options specifying the webview and its new frame |

**Since:** 1.0.0

--------------------


### executeJavaScript(...)

```typescript
executeJavaScript(options: ExecuteJavaScriptOptions) => Promise<ExecuteJavaScriptResult>
```

Execute JavaScript code in the specified webview.

| Param         | Type                                                                          | Description                                              |
| ------------- | ----------------------------------------------------------------------------- | -------------------------------------------------------- |
| **`options`** | <code><a href="#executejavascriptoptions">ExecuteJavaScriptOptions</a></code> | Options specifying the webview and JavaScript to execute |

**Returns:** <code>Promise&lt;<a href="#executejavascriptresult">ExecuteJavaScriptResult</a>&gt;</code>

**Since:** 1.0.0

--------------------


### sendMessage(...)

```typescript
sendMessage(options: SendMessageOptions) => Promise<void>
```

Send a message to the specified webview.
The webview can listen for these messages using the MultiWebview.addListener('message', ...) method.

| Param         | Type                                                              | Description                                        |
| ------------- | ----------------------------------------------------------------- | -------------------------------------------------- |
| **`options`** | <code><a href="#sendmessageoptions">SendMessageOptions</a></code> | Options specifying the webview and message to send |

**Since:** 1.0.0

--------------------


### addListener('message', ...)

```typescript
addListener(eventName: 'message', listenerFunc: (event: MessageEvent) => void) => Promise<PluginListenerHandle>
```

Add a listener for messages from webviews.

| Param              | Type                                                                      | Description                                     |
| ------------------ | ------------------------------------------------------------------------- | ----------------------------------------------- |
| **`eventName`**    | <code>'message'</code>                                                    | The event name ('message')                      |
| **`listenerFunc`** | <code>(event: <a href="#messageevent">MessageEvent</a>) =&gt; void</code> | The function to call when a message is received |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

**Since:** 1.0.0

--------------------


### addListener('webviewCreated' | 'webviewDestroyed' | 'webviewFocused', ...)

```typescript
addListener(eventName: 'webviewCreated' | 'webviewDestroyed' | 'webviewFocused', listenerFunc: (event: WebviewLifecycleEvent) => void) => Promise<PluginListenerHandle>
```

Add a listener for webview lifecycle events.

| Param              | Type                                                                                        | Description                                                             |
| ------------------ | ------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| **`eventName`**    | <code>'webviewCreated' \| 'webviewDestroyed' \| 'webviewFocused'</code>                     | The event name ('webviewCreated', 'webviewDestroyed', 'webviewFocused') |
| **`listenerFunc`** | <code>(event: <a href="#webviewlifecycleevent">WebviewLifecycleEvent</a>) =&gt; void</code> | The function to call when the event occurs                              |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

**Since:** 1.0.0

--------------------


### addListener('loadStart' | 'loadFinish' | 'loadError', ...)

```typescript
addListener(eventName: 'loadStart' | 'loadFinish' | 'loadError', listenerFunc: (event: WebviewLoadEvent) => void) => Promise<PluginListenerHandle>
```

Add a listener for webview load events.

| Param              | Type                                                                              | Description                                             |
| ------------------ | --------------------------------------------------------------------------------- | ------------------------------------------------------- |
| **`eventName`**    | <code>'loadStart' \| 'loadFinish' \| 'loadError'</code>                           | The event name ('loadStart', 'loadFinish', 'loadError') |
| **`listenerFunc`** | <code>(event: <a href="#webviewloadevent">WebviewLoadEvent</a>) =&gt; void</code> | The function to call when the event occurs              |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

**Since:** 1.0.0

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

Remove all listeners for this plugin.

**Since:** 1.0.0

--------------------


### Interfaces


#### CreateWebviewOptions

Options for creating a new webview

| Prop                   | Type                                                  | Description                                                                |
| ---------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------- |
| **`id`**               | <code>string</code>                                   | Unique identifier for the webview                                          |
| **`url`**              | <code>string</code>                                   | Initial URL to load in the webview (optional)                              |
| **`frame`**            | <code><a href="#webviewframe">WebviewFrame</a></code> | Frame/bounds of the webview (optional, defaults to full screen)            |
| **`autoFocus`**        | <code>boolean</code>                                  | Whether to automatically focus this webview after creation (default: true) |
| **`enableJavaScript`** | <code>boolean</code>                                  | Whether to enable JavaScript in the webview (default: true)                |
| **`allowFileAccess`**  | <code>boolean</code>                                  | Whether to allow file access (default: false)                              |
| **`userAgent`**        | <code>string</code>                                   | User agent string (optional)                                               |


#### WebviewFrame

Frame/bounds for a webview

| Prop         | Type                | Description                     |
| ------------ | ------------------- | ------------------------------- |
| **`x`**      | <code>number</code> | X coordinate (in points/pixels) |
| **`y`**      | <code>number</code> | Y coordinate (in points/pixels) |
| **`width`**  | <code>number</code> | Width (in points/pixels)        |
| **`height`** | <code>number</code> | Height (in points/pixels)       |


#### SetFocusedWebviewOptions

Options for setting the focused webview

| Prop     | Type                | Description                        |
| -------- | ------------------- | ---------------------------------- |
| **`id`** | <code>string</code> | Identifier of the webview to focus |


#### FocusedWebviewResult

Result of getting the focused webview

| Prop     | Type                        | Description                                                  |
| -------- | --------------------------- | ------------------------------------------------------------ |
| **`id`** | <code>string \| null</code> | Identifier of the currently focused webview, or null if none |


#### WebviewIdentifier

Identifier for a webview

| Prop     | Type                | Description               |
| -------- | ------------------- | ------------------------- |
| **`id`** | <code>string</code> | Identifier of the webview |


#### LoadUrlOptions

Options for loading a URL in a webview

| Prop      | Type                | Description               |
| --------- | ------------------- | ------------------------- |
| **`id`**  | <code>string</code> | Identifier of the webview |
| **`url`** | <code>string</code> | URL to load               |


#### ListWebviewsResult

Result of listing webviews

| Prop           | Type                  | Description                  |
| -------------- | --------------------- | ---------------------------- |
| **`webviews`** | <code>string[]</code> | Array of webview identifiers |


#### WebviewInfo

Detailed information about a webview

| Prop            | Type                        | Description                                                      |
| --------------- | --------------------------- | ---------------------------------------------------------------- |
| **`id`**        | <code>string</code>         | Identifier of the webview                                        |
| **`url`**       | <code>string \| null</code> | Current URL loaded in the webview (may be null if no URL loaded) |
| **`isHidden`**  | <code>boolean</code>        | Whether this webview is currently hidden                         |
| **`isFocused`** | <code>boolean</code>        | Whether this webview is currently focused                        |


#### AllWebviewsResult

Result of getting all webviews with details

| Prop           | Type                       | Description                          |
| -------------- | -------------------------- | ------------------------------------ |
| **`webviews`** | <code>WebviewInfo[]</code> | Array of webview information objects |


#### WebviewsByUrlResult

Result of getting webviews by URL

| Prop           | Type                  | Description                                              |
| -------------- | --------------------- | -------------------------------------------------------- |
| **`webviews`** | <code>string[]</code> | Array of webview identifiers that match the URL criteria |


#### GetWebviewsByUrlOptions

Options for getting webviews by URL

| Prop             | Type                 | Description                                                                    |
| ---------------- | -------------------- | ------------------------------------------------------------------------------ |
| **`url`**        | <code>string</code>  | URL to search for (exact match or contains, depending on exactMatch parameter) |
| **`exactMatch`** | <code>boolean</code> | Whether to use exact match (true) or contains match (false, default)           |


#### SetWebviewFrameOptions

Options for setting a webview's frame

| Prop        | Type                                                  | Description               |
| ----------- | ----------------------------------------------------- | ------------------------- |
| **`id`**    | <code>string</code>                                   | Identifier of the webview |
| **`frame`** | <code><a href="#webviewframe">WebviewFrame</a></code> | New frame for the webview |


#### ExecuteJavaScriptResult

Result of executing JavaScript

| Prop         | Type                | Description                                                 |
| ------------ | ------------------- | ----------------------------------------------------------- |
| **`result`** | <code>string</code> | Result value from the JavaScript execution (as JSON string) |


#### ExecuteJavaScriptOptions

Options for executing JavaScript in a webview

| Prop       | Type                | Description                |
| ---------- | ------------------- | -------------------------- |
| **`id`**   | <code>string</code> | Identifier of the webview  |
| **`code`** | <code>string</code> | JavaScript code to execute |


#### SendMessageOptions

Options for sending a message to a webview

| Prop       | Type                | Description                                    |
| ---------- | ------------------- | ---------------------------------------------- |
| **`id`**   | <code>string</code> | Identifier of the webview                      |
| **`data`** | <code>any</code>    | Message data to send (will be JSON serialized) |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### MessageEvent

Event received when a webview sends a message

| Prop       | Type                | Description                                     |
| ---------- | ------------------- | ----------------------------------------------- |
| **`id`**   | <code>string</code> | Identifier of the webview that sent the message |
| **`data`** | <code>any</code>    | Message data                                    |


#### WebviewLifecycleEvent

Event for webview lifecycle changes

| Prop     | Type                | Description               |
| -------- | ------------------- | ------------------------- |
| **`id`** | <code>string</code> | Identifier of the webview |


#### WebviewLoadEvent

Event for webview load status

| Prop        | Type                | Description                              |
| ----------- | ------------------- | ---------------------------------------- |
| **`id`**    | <code>string</code> | Identifier of the webview                |
| **`url`**   | <code>string</code> | URL being loaded                         |
| **`error`** | <code>string</code> | Error message (only for loadError event) |

</docgen-api>
