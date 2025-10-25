package net.bitburst.plugins.multiwebview;

import android.util.Log;
import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import org.json.JSONException;

@CapacitorPlugin(name = "MultiWebview")
public class MultiWebviewPlugin extends Plugin {

    private static final String TAG = "MultiWebview";
    private MultiWebviewManager manager;

    @Override
    public void load() {
        super.load();
        manager = new MultiWebviewManager(this);
    }

    @PluginMethod
    public void createWebview(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        String url = call.getString("url");
        Boolean autoFocus = call.getBoolean("autoFocus", true);
        Boolean enableJavaScript = call.getBoolean("enableJavaScript", true);
        Boolean allowFileAccess = call.getBoolean("allowFileAccess", false);
        String userAgent = call.getString("userAgent");

        JSObject frameObj = call.getObject("frame");
        WebviewFrame frame = null;
        if (frameObj != null) {
            try {
                frame = new WebviewFrame(
                    frameObj.getDouble("x", 0.0),
                    frameObj.getDouble("y", 0.0),
                    frameObj.getDouble("width", 0.0),
                    frameObj.getDouble("height", 0.0)
                );
            } catch (Exception e) {
                Log.e(TAG, "Error parsing frame", e);
            }
        }

        WebviewFrame finalFrame = frame;
        getActivity().runOnUiThread(() -> {
            try {
                manager.createWebview(
                    id,
                    url,
                    finalFrame,
                    autoFocus,
                    enableJavaScript,
                    allowFileAccess,
                    userAgent
                );

                JSObject data = new JSObject();
                data.put("id", id);
                notifyListeners("webviewCreated", data);

                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to create webview: " + e.getMessage(), e);
            }
        });
    }

    @PluginMethod
    public void setFocusedWebview(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        getActivity().runOnUiThread(() -> {
            try {
                manager.setFocusedWebview(id);

                JSObject data = new JSObject();
                data.put("id", id);
                notifyListeners("webviewFocused", data);

                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to focus webview: " + e.getMessage(), e);
            }
        });
    }

    @PluginMethod
    public void getFocusedWebview(PluginCall call) {
        String focusedId = manager.getFocusedWebviewId();
        JSObject result = new JSObject();
        result.put("id", focusedId);
        call.resolve(result);
    }

    @PluginMethod
    public void hideWebview(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        getActivity().runOnUiThread(() -> {
            try {
                manager.hideWebview(id);
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to hide webview: " + e.getMessage(), e);
            }
        });
    }

    @PluginMethod
    public void showWebview(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        getActivity().runOnUiThread(() -> {
            try {
                manager.showWebview(id);
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to show webview: " + e.getMessage(), e);
            }
        });
    }

    @PluginMethod
    public void destroyWebview(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        getActivity().runOnUiThread(() -> {
            try {
                manager.destroyWebview(id);

                JSObject data = new JSObject();
                data.put("id", id);
                notifyListeners("webviewDestroyed", data);

                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to destroy webview: " + e.getMessage(), e);
            }
        });
    }

    @PluginMethod
    public void loadUrl(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        String url = call.getString("url");
        if (url == null || url.isEmpty()) {
            call.reject("Must provide url");
            return;
        }

        getActivity().runOnUiThread(() -> {
            try {
                manager.loadUrl(id, url);
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to load URL: " + e.getMessage(), e);
            }
        });
    }

    @PluginMethod
    public void listWebviews(PluginCall call) {
        try {
            JSArray webviews = new JSArray(manager.listWebviews());
            JSObject result = new JSObject();
            result.put("webviews", webviews);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to list webviews: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void getWebviewInfo(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        try {
            JSObject info = manager.getWebviewInfo(id);
            call.resolve(info);
        } catch (Exception e) {
            call.reject("Failed to get webview info: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void getAllWebviews(PluginCall call) {
        try {
            List<JSObject> webviewsList = manager.getAllWebviews();
            JSArray webviews = new JSArray();
            for (JSObject webview : webviewsList) {
                webviews.put(webview);
            }
            JSObject result = new JSObject();
            result.put("webviews", webviews);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to get all webviews: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void getWebviewsByUrl(PluginCall call) {
        String url = call.getString("url");
        if (url == null || url.isEmpty()) {
            call.reject("Must provide url");
            return;
        }

        Boolean exactMatch = call.getBoolean("exactMatch", false);

        try {
            List<String> matchingWebviews = manager.getWebviewsByUrl(url, exactMatch);
            JSArray webviews = new JSArray(matchingWebviews);
            JSObject result = new JSObject();
            result.put("webviews", webviews);
            call.resolve(result);
        } catch (Exception e) {
            call.reject("Failed to get webviews by URL: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void setWebviewFrame(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        JSObject frameObj = call.getObject("frame");
        if (frameObj == null) {
            call.reject("Must provide frame");
            return;
        }

        try {
            WebviewFrame frame = new WebviewFrame(
                frameObj.getDouble("x", 0.0),
                frameObj.getDouble("y", 0.0),
                frameObj.getDouble("width", 0.0),
                frameObj.getDouble("height", 0.0)
            );

            getActivity().runOnUiThread(() -> {
                try {
                    manager.setWebviewFrame(id, frame);
                    call.resolve();
                } catch (Exception e) {
                    call.reject("Failed to set webview frame: " + e.getMessage(), e);
                }
            });
        } catch (Exception e) {
            call.reject("Invalid frame data: " + e.getMessage(), e);
        }
    }

    @PluginMethod
    public void executeJavaScript(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        String code = call.getString("code");
        if (code == null || code.isEmpty()) {
            call.reject("Must provide code to execute");
            return;
        }

        getActivity().runOnUiThread(() -> {
            try {
                manager.executeJavaScript(id, code, result -> {
                    JSObject response = new JSObject();
                    response.put("result", result);
                    call.resolve(response);
                });
            } catch (Exception e) {
                call.reject("Failed to execute JavaScript: " + e.getMessage(), e);
            }
        });
    }

    @PluginMethod
    public void sendMessage(PluginCall call) {
        String id = call.getString("id");
        if (id == null || id.isEmpty()) {
            call.reject("Must provide webview id");
            return;
        }

        Object data = call.getData().opt("data");
        if (data == null) {
            call.reject("Must provide data");
            return;
        }

        getActivity().runOnUiThread(() -> {
            try {
                manager.sendMessage(id, data);
                call.resolve();
            } catch (Exception e) {
                call.reject("Failed to send message: " + e.getMessage(), e);
            }
        });
    }

    public void notifyEvent(String eventName, JSObject data) {
        notifyListeners(eventName, data);
    }
}
