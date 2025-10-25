export interface MsAppMultiWebviewPlugin {
    /**
     * Create a new webview with the specified identifier and configuration.
     *
     * @param options Configuration for creating the webview
     * @returns Promise that resolves when the webview is created
     * @since 1.0.0
     */
    createWebview(options: CreateWebviewOptions): Promise<void>

    /**
     * Bring the specified webview to the foreground and give it focus.
     *
     * @param options Options specifying which webview to focus
     * @returns Promise that resolves when the webview is focused
     * @since 1.0.0
     */
    setFocusedWebview(options: SetFocusedWebviewOptions): Promise<void>

    /**
     * Get the identifier of the currently focused webview.
     *
     * @returns Promise that resolves with the focused webview info
     * @since 1.0.0
     */
    getFocusedWebview(): Promise<FocusedWebviewResult>

    /**
     * Hide the specified webview (removes from view but keeps in memory).
     *
     * @param options Options specifying which webview to hide
     * @returns Promise that resolves when the webview is hidden
     * @since 1.0.0
     */
    hideWebview(options: WebviewIdentifier): Promise<void>

    /**
     * Show a previously hidden webview.
     *
     * @param options Options specifying which webview to show
     * @returns Promise that resolves when the webview is shown
     * @since 1.0.0
     */
    showWebview(options: WebviewIdentifier): Promise<void>

    /**
     * Destroy the specified webview and free its resources.
     *
     * @param options Options specifying which webview to destroy
     * @returns Promise that resolves when the webview is destroyed
     * @since 1.0.0
     */
    destroyWebview(options: WebviewIdentifier): Promise<void>

    /**
     * Load a URL in the specified webview.
     *
     * @param options Options specifying the webview and URL to load
     * @returns Promise that resolves when the URL starts loading
     * @since 1.0.0
     */
    loadUrl(options: LoadUrlOptions): Promise<void>

    /**
     * Get a list of all webview identifiers currently managed by the plugin.
     *
     * @returns Promise that resolves with the list of webview identifiers
     * @since 1.0.0
     */
    listWebviews(): Promise<ListWebviewsResult>

    /**
     * Get detailed information about a specific webview.
     *
     * @param options Options specifying which webview to get info for
     * @returns Promise that resolves with the webview information
     * @since 1.0.0
     */
    getWebviewInfo(options: WebviewIdentifier): Promise<WebviewInfo>

    /**
     * Get detailed information about all webviews.
     *
     * @returns Promise that resolves with array of webview information
     * @since 1.0.0
     */
    getAllWebviews(): Promise<AllWebviewsResult>

    /**
     * Get webviews that match a specific URL or URL pattern.
     *
     * @param options Options specifying the URL to search for
     * @returns Promise that resolves with array of matching webview IDs
     * @since 1.0.0
     */
    getWebviewsByUrl(options: GetWebviewsByUrlOptions): Promise<WebviewsByUrlResult>

    /**
     * Set the frame/bounds of the specified webview.
     *
     * @param options Options specifying the webview and its new frame
     * @returns Promise that resolves when the frame is updated
     * @since 1.0.0
     */
    setWebviewFrame(options: SetWebviewFrameOptions): Promise<void>

    /**
     * Execute JavaScript code in the specified webview.
     *
     * @param options Options specifying the webview and JavaScript to execute
     * @returns Promise that resolves with the result of the JavaScript execution
     * @since 1.0.0
     */
    executeJavaScript(options: ExecuteJavaScriptOptions): Promise<ExecuteJavaScriptResult>

    /**
     * Send a message to the specified webview.
     * The webview can listen for these messages using the MsAppMultiWebview.addListener('message', ...) method.
     *
     * @param options Options specifying the webview and message to send
     * @returns Promise that resolves when the message is sent
     * @since 1.0.0
     */
    sendMessage(options: SendMessageOptions): Promise<void>

    /**
     * Add a listener for messages from webviews.
     *
     * @param eventName The event name ('message')
     * @param listenerFunc The function to call when a message is received
     * @returns A promise with a remove function
     * @since 1.0.0
     */
    addListener(eventName: 'message', listenerFunc: (event: MessageEvent) => void): Promise<PluginListenerHandle>

    /**
     * Add a listener for webview lifecycle events.
     *
     * @param eventName The event name ('webviewCreated', 'webviewDestroyed', 'webviewFocused')
     * @param listenerFunc The function to call when the event occurs
     * @returns A promise with a remove function
     * @since 1.0.0
     */
    addListener(
        eventName: 'webviewCreated' | 'webviewDestroyed' | 'webviewFocused',
        listenerFunc: (event: WebviewLifecycleEvent) => void,
    ): Promise<PluginListenerHandle>

    /**
     * Add a listener for webview load events.
     *
     * @param eventName The event name ('loadStart', 'loadFinish', 'loadError')
     * @param listenerFunc The function to call when the event occurs
     * @returns A promise with a remove function
     * @since 1.0.0
     */
    addListener(
        eventName: 'loadStart' | 'loadFinish' | 'loadError',
        listenerFunc: (event: WebviewLoadEvent) => void,
    ): Promise<PluginListenerHandle>

    /**
     * Remove all listeners for this plugin.
     *
     * @since 1.0.0
     */
    removeAllListeners(): Promise<void>
}

/**
 * Options for creating a new webview
 */
export interface CreateWebviewOptions {
    /**
     * Unique identifier for the webview
     */
    id: string

    /**
     * Initial URL to load in the webview (optional)
     */
    url?: string

    /**
     * Frame/bounds of the webview (optional, defaults to full screen)
     */
    frame?: WebviewFrame

    /**
     * Whether to automatically focus this webview after creation (default: true)
     */
    autoFocus?: boolean

    /**
     * Whether to enable JavaScript in the webview (default: true)
     */
    enableJavaScript?: boolean

    /**
     * Whether to allow file access (default: false)
     */
    allowFileAccess?: boolean

    /**
     * User agent string (optional)
     */
    userAgent?: string
}

/**
 * Options for setting the focused webview
 */
export interface SetFocusedWebviewOptions {
    /**
     * Identifier of the webview to focus
     */
    id: string
}

/**
 * Result of getting the focused webview
 */
export interface FocusedWebviewResult {
    /**
     * Identifier of the currently focused webview, or null if none
     */
    id: string | null
}

/**
 * Identifier for a webview
 */
export interface WebviewIdentifier {
    /**
     * Identifier of the webview
     */
    id: string
}

/**
 * Options for loading a URL in a webview
 */
export interface LoadUrlOptions {
    /**
     * Identifier of the webview
     */
    id: string

    /**
     * URL to load
     */
    url: string
}

/**
 * Result of listing webviews
 */
export interface ListWebviewsResult {
    /**
     * Array of webview identifiers
     */
    webviews: string[]
}

/**
 * Detailed information about a webview
 */
export interface WebviewInfo {
    /**
     * Identifier of the webview
     */
    id: string

    /**
     * Current URL loaded in the webview (may be null if no URL loaded)
     */
    url: string | null

    /**
     * Whether this webview is currently hidden
     */
    isHidden: boolean

    /**
     * Whether this webview is currently focused
     */
    isFocused: boolean
}

/**
 * Result of getting all webviews with details
 */
export interface AllWebviewsResult {
    /**
     * Array of webview information objects
     */
    webviews: WebviewInfo[]
}

/**
 * Options for getting webviews by URL
 */
export interface GetWebviewsByUrlOptions {
    /**
     * URL to search for (exact match or contains, depending on exactMatch parameter)
     */
    url: string

    /**
     * Whether to use exact match (true) or contains match (false, default)
     */
    exactMatch?: boolean
}

/**
 * Result of getting webviews by URL
 */
export interface WebviewsByUrlResult {
    /**
     * Array of webview identifiers that match the URL criteria
     */
    webviews: string[]
}

/**
 * Frame/bounds for a webview
 */
export interface WebviewFrame {
    /**
     * X coordinate (in points/pixels)
     */
    x: number

    /**
     * Y coordinate (in points/pixels)
     */
    y: number

    /**
     * Width (in points/pixels)
     */
    width: number

    /**
     * Height (in points/pixels)
     */
    height: number
}

/**
 * Options for setting a webview's frame
 */
export interface SetWebviewFrameOptions {
    /**
     * Identifier of the webview
     */
    id: string

    /**
     * New frame for the webview
     */
    frame: WebviewFrame
}

/**
 * Options for executing JavaScript in a webview
 */
export interface ExecuteJavaScriptOptions {
    /**
     * Identifier of the webview
     */
    id: string

    /**
     * JavaScript code to execute
     */
    code: string
}

/**
 * Result of executing JavaScript
 */
export interface ExecuteJavaScriptResult {
    /**
     * Result value from the JavaScript execution (as JSON string)
     */
    result?: string
}

/**
 * Options for sending a message to a webview
 */
export interface SendMessageOptions {
    /**
     * Identifier of the webview
     */
    id: string

    /**
     * Message data to send (will be JSON serialized)
     */
    data: unknown
}

/**
 * Event received when a webview sends a message
 */
export interface MessageEvent {
    /**
     * Identifier of the webview that sent the message
     */
    id: string

    /**
     * Message data
     */
    data: unknown
}

/**
 * Event for webview lifecycle changes
 */
export interface WebviewLifecycleEvent {
    /**
     * Identifier of the webview
     */
    id: string
}

/**
 * Event for webview load status
 */
export interface WebviewLoadEvent {
    /**
     * Identifier of the webview
     */
    id: string

    /**
     * URL being loaded
     */
    url: string

    /**
     * Error message (only for loadError event)
     */
    error?: string
}

/**
 * Handle for a plugin listener
 */
export interface PluginListenerHandle {
    remove: () => Promise<void>
}
