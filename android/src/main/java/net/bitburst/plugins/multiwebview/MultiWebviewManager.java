package net.bitburst.plugins.multiwebview;

import android.annotation.SuppressLint;
import android.graphics.Color;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import com.getcapacitor.JSObject;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONObject;

public class MultiWebviewManager {

    private static final String TAG = "MultiWebviewManager";
    private final MultiWebviewPlugin plugin;
    private final Map<String, WebviewContainer> webviews = new HashMap<>();
    private String focusedWebviewId = null;

    public MultiWebviewManager(MultiWebviewPlugin plugin) {
        this.plugin = plugin;
    }

    @SuppressLint("SetJavaScriptEnabled")
    public void createWebview(
        String id,
        String url,
        WebviewFrame frame,
        Boolean autoFocus,
        Boolean enableJavaScript,
        Boolean allowFileAccess,
        String userAgent
    ) throws Exception {
        if (webviews.containsKey(id)) {
            throw new Exception("Webview with id '" + id + "' already exists");
        }

        // Get the root view group
        ViewGroup rootView = (ViewGroup) plugin.getBridge().getWebView().getParent();

        // Create WebView
        WebView webView = new WebView(plugin.getContext());

        // Configure settings
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(enableJavaScript);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(allowFileAccess);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_ALWAYS_ALLOW);

        if (userAgent != null && !userAgent.isEmpty()) {
            settings.setUserAgentString(userAgent);
        }

        // Add JavaScript interface for receiving messages from webview
        webView.addJavascriptInterface(new MessageHandler(id), "MultiWebviewBridge");

        // Set WebViewClient for navigation events
        webView.setWebViewClient(
            new WebViewClient() {
                @Override
                public void onPageStarted(WebView view, String url, android.graphics.Bitmap favicon) {
                    JSObject data = new JSObject();
                    data.put("id", id);
                    data.put("url", url);
                    plugin.notifyEvent("loadStart", data);
                }

                @Override
                public void onPageFinished(WebView view, String url) {
                    // Update current URL in container
                    WebviewContainer container = webviews.get(id);
                    if (container != null) {
                        container.setCurrentUrl(url);
                    }

                    JSObject data = new JSObject();
                    data.put("id", id);
                    data.put("url", url);
                    plugin.notifyEvent("loadFinish", data);
                }

                @Override
                public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
                    JSObject data = new JSObject();
                    data.put("id", id);
                    data.put("url", request.getUrl().toString());
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                        data.put("error", error.getDescription().toString());
                    }
                    plugin.notifyEvent("loadError", data);
                }
            }
        );

        // Set WebChromeClient
        webView.setWebChromeClient(new WebChromeClient());

        // Set frame
        FrameLayout.LayoutParams layoutParams;
        if (frame != null) {
            DisplayMetrics metrics = plugin.getContext().getResources().getDisplayMetrics();
            int x = (int) (frame.x * metrics.density);
            int y = (int) (frame.y * metrics.density);
            int width = (int) (frame.width * metrics.density);
            int height = (int) (frame.height * metrics.density);

            layoutParams = new FrameLayout.LayoutParams(width, height);
            layoutParams.leftMargin = x;
            layoutParams.topMargin = y;
        } else {
            layoutParams = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            );
        }

        webView.setLayoutParams(layoutParams);
        webView.setBackgroundColor(Color.WHITE);

        // Create container
        WebviewContainer container = new WebviewContainer(id, webView);
        webviews.put(id, container);

        // Add to view hierarchy
        rootView.addView(webView);

        // Load URL if provided
        if (url != null && !url.isEmpty()) {
            webView.loadUrl(url);
        }

        // Handle focus
        if (autoFocus) {
            setFocusedWebview(id);
        } else if (focusedWebviewId == null && webviews.size() == 1) {
            setFocusedWebview(id);
        } else {
            webView.setVisibility(View.GONE);
            container.setHidden(true);
        }
    }

    public void setFocusedWebview(String id) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        // Hide all other webviews
        for (Map.Entry<String, WebviewContainer> entry : webviews.entrySet()) {
            if (!entry.getKey().equals(id)) {
                entry.getValue().getWebView().setVisibility(View.GONE);
                entry.getValue().setHidden(true);
            }
        }

        // Show and bring to front the focused webview
        container.getWebView().setVisibility(View.VISIBLE);
        container.setHidden(false);
        container.getWebView().bringToFront();

        focusedWebviewId = id;
    }

    public String getFocusedWebviewId() {
        return focusedWebviewId;
    }

    public void hideWebview(String id) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        container.getWebView().setVisibility(View.GONE);
        container.setHidden(true);

        if (id.equals(focusedWebviewId)) {
            focusedWebviewId = null;
        }
    }

    public void showWebview(String id) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        container.getWebView().setVisibility(View.VISIBLE);
        container.setHidden(false);
    }

    public void destroyWebview(String id) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        ViewGroup rootView = (ViewGroup) plugin.getBridge().getWebView().getParent();
        rootView.removeView(container.getWebView());
        container.getWebView().destroy();
        webviews.remove(id);

        if (id.equals(focusedWebviewId)) {
            focusedWebviewId = null;
        }
    }

    public void loadUrl(String id, String url) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        container.getWebView().loadUrl(url);
    }

    public List<String> listWebviews() {
        return new ArrayList<>(webviews.keySet());
    }

    public JSObject getWebviewInfo(String id) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        JSObject info = new JSObject();
        info.put("id", id);
        info.put("url", container.getCurrentUrl());
        info.put("isHidden", container.isHidden());
        info.put("isFocused", id.equals(focusedWebviewId));
        return info;
    }

    public List<JSObject> getAllWebviews() {
        List<JSObject> result = new ArrayList<>();
        for (Map.Entry<String, WebviewContainer> entry : webviews.entrySet()) {
            String id = entry.getKey();
            WebviewContainer container = entry.getValue();

            JSObject info = new JSObject();
            info.put("id", id);
            info.put("url", container.getCurrentUrl());
            info.put("isHidden", container.isHidden());
            info.put("isFocused", id.equals(focusedWebviewId));
            result.add(info);
        }
        return result;
    }

    public List<String> getWebviewsByUrl(String urlString, boolean exactMatch) {
        List<String> result = new ArrayList<>();
        for (Map.Entry<String, WebviewContainer> entry : webviews.entrySet()) {
            String id = entry.getKey();
            WebviewContainer container = entry.getValue();
            String currentUrl = container.getCurrentUrl();

            if (currentUrl != null) {
                if (exactMatch) {
                    if (currentUrl.equals(urlString)) {
                        result.add(id);
                    }
                } else {
                    if (currentUrl.contains(urlString)) {
                        result.add(id);
                    }
                }
            }
        }
        return result;
    }

    public void setWebviewFrame(String id, WebviewFrame frame) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        DisplayMetrics metrics = plugin.getContext().getResources().getDisplayMetrics();
        int x = (int) (frame.x * metrics.density);
        int y = (int) (frame.y * metrics.density);
        int width = (int) (frame.width * metrics.density);
        int height = (int) (frame.height * metrics.density);

        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(width, height);
        layoutParams.leftMargin = x;
        layoutParams.topMargin = y;

        container.getWebView().setLayoutParams(layoutParams);
    }

    public void executeJavaScript(String id, String code, ValueCallback<String> callback) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        container.getWebView().evaluateJavascript(code, callback);
    }

    public void sendMessage(String id, Object data) throws Exception {
        WebviewContainer container = webviews.get(id);
        if (container == null) {
            throw new Exception("Webview with id '" + id + "' not found");
        }

        // Convert data to JSON string
        String jsonString = new JSONObject(Map.of("data", data)).toString();

        // Escape for JavaScript
        String escapedJson = jsonString.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r");

        // Inject JavaScript to dispatch custom event
        String script = "javascript:(function() {" + "var event = new CustomEvent('multiwebview-message', {" + "detail: " + escapedJson + "" + "});" + "window.dispatchEvent(event);" + "})();";

        container.getWebView().loadUrl(script);
    }

    // JavaScript interface for receiving messages from webviews
    private class MessageHandler {

        private final String webviewId;

        MessageHandler(String webviewId) {
            this.webviewId = webviewId;
        }

        @JavascriptInterface
        public void postMessage(String message) {
            try {
                JSObject data = new JSObject();
                data.put("id", webviewId);
                data.put("data", new JSONObject(message));
                plugin.notifyEvent("message", data);
            } catch (Exception e) {
                Log.e(TAG, "Error handling message", e);
            }
        }
    }

    private static class WebviewContainer {

        private final String id;
        private final WebView webView;
        private boolean isHidden = false;
        private String currentUrl = null;

        WebviewContainer(String id, WebView webView) {
            this.id = id;
            this.webView = webView;
        }

        public String getId() {
            return id;
        }

        public WebView getWebView() {
            return webView;
        }

        public boolean isHidden() {
            return isHidden;
        }

        public void setHidden(boolean hidden) {
            isHidden = hidden;
        }

        public String getCurrentUrl() {
            return currentUrl;
        }

        public void setCurrentUrl(String currentUrl) {
            this.currentUrl = currentUrl;
        }
    }
}
