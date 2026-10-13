package com.saif.browser.engine

import android.annotation.SuppressLint
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import android.net.http.SslError
import android.os.Build
import android.os.Bundle
import android.os.Message
import android.view.View
import android.view.ViewGroup
import android.webkit.ConsoleMessage
import android.webkit.GeolocationPermissions
import android.webkit.HttpAuthHandler
import android.webkit.PermissionRequest
import android.webkit.RenderProcessGoneDetail
import android.webkit.SslErrorHandler
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import org.json.JSONObject
import java.io.ByteArrayOutputStream

/**
 * One browser tab backed by one Android [WebView]. The WebView can be
 * suspended (destroyed with its state saved in memory) and restored later,
 * which keeps memory bounded when many tabs are open.
 */
@SuppressLint("SetJavaScriptEnabled")
class BrowserTab(
    val id: String,
    val incognito: Boolean,
    private val engine: BrowserEngine,
) {
    var webView: WebView? = null
        private set
    private var savedState: Bundle? = null
    private var pendingUrl: String? = null
    private var lastMainFrameUrl: String? = null
    var desktopMode: Boolean = false
        private set
    var textZoomOverride: Int? = null
        private set
    var lastKnownUrl: String? = null
        private set

    val isAlive: Boolean get() = webView != null

    /** Returns the live WebView, creating or restoring it when needed. */
    fun obtainWebView(): WebView {
        webView?.let { return it }
        val view = createWebView()
        webView = view
        val state = savedState
        savedState = null
        val restored = state != null && view.restoreState(state) != null
        if (!restored) {
            val url = pendingUrl ?: lastKnownUrl
            pendingUrl = null
            if (!url.isNullOrEmpty()) loadUrl(url)
        }
        return view
    }

    /** Creates the WebView for a popup window without loading anything. */
    fun createForPopup(): WebView {
        val view = createWebView()
        webView = view
        return view
    }

    fun loadUrl(url: String) {
        val view = webView
        if (view == null) {
            pendingUrl = url
            savedState = null
            return
        }
        lastMainFrameUrl = url
        lastKnownUrl = url
        view.loadUrl(url)
    }

    private fun createWebView(): WebView {
        // An Activity context is required for <select> popups, JS dialogs,
        // autofill and full-screen video.
        val view = WebView(engine.host.context)
        if (incognito) engine.profiles.attachIncognitoProfile(view)
        view.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT,
        )
        view.isFocusable = true
        view.isFocusableInTouchMode = true
        view.isScrollbarFadingEnabled = true
        view.overScrollMode = View.OVER_SCROLL_IF_CONTENT_SCROLLS
        if (incognito && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Keep private form input away from autofill services.
            view.importantForAutofill = View.IMPORTANT_FOR_AUTOFILL_NO_EXCLUDE_DESCENDANTS
        }
        view.settings.apply {
            domStorageEnabled = true
            setSupportZoom(true)
            builtInZoomControls = true
            displayZoomControls = false
            loadWithOverviewMode = true
            useWideViewPort = true
            setSupportMultipleWindows(true)
            mediaPlaybackRequiresUserGesture = true
            mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
            allowFileAccess = false
            allowContentAccess = false
            setGeolocationEnabled(true)
            if (incognito && !engine.profiles.isolationSupported) {
                // Without a separate profile, avoid writing pages to the shared disk cache.
                cacheMode = WebSettings.LOAD_NO_CACHE
            }
        }
        applySettings(view, engine.settings)
        view.webViewClient = Client()
        view.webChromeClient = ChromeClient()
        view.setDownloadListener { url, userAgent, contentDisposition, mimeType, contentLength ->
            engine.emit(
                id,
                "download",
                mapOf(
                    "url" to url,
                    "userAgent" to userAgent,
                    "contentDisposition" to contentDisposition,
                    "mimeType" to mimeType,
                    "contentLength" to contentLength,
                    "pageUrl" to view.url,
                ),
            )
        }
        view.setOnLongClickListener { emitContextMenu(view) }
        if (!incognito) installCredentialListener(view)
        view.setFindListener { activeMatchOrdinal, numberOfMatches, isDoneCounting ->
            engine.emit(
                id,
                "findResult",
                mapOf(
                    "active" to if (numberOfMatches == 0) 0 else activeMatchOrdinal + 1,
                    "total" to numberOfMatches,
                    "done" to isDoneCounting,
                ),
            )
        }
        return view
    }

    fun applySettings(settings: EngineSettings) {
        webView?.let { applySettings(it, settings) }
    }

    private fun applySettings(view: WebView, settings: EngineSettings) {
        val ws = view.settings
        ws.javaScriptEnabled = settings.javaScriptEnabled
        ws.javaScriptCanOpenWindowsAutomatically = !settings.blockPopups
        ws.textZoom = textZoomOverride ?: settings.textZoom
        val ua = if (desktopMode) settings.desktopUserAgent else settings.mobileUserAgent
        ws.userAgentString = ua
        ws.useWideViewPort = true
        ws.loadWithOverviewMode = true
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            ws.safeBrowsingEnabled = settings.safeBrowsing
        }
        val cookies = engine.profiles.cookieManagerFor(view, incognito)
        cookies.setAcceptCookie(settings.acceptCookies)
        cookies.setAcceptThirdPartyCookies(view, settings.acceptCookies && settings.thirdPartyCookies)
    }

    fun setDesktopMode(enabled: Boolean, reload: Boolean) {
        desktopMode = enabled
        val view = webView ?: return
        applySettings(view, engine.settings)
        if (reload) view.reload()
    }

    fun setTextZoom(percent: Int?) {
        textZoomOverride = percent?.coerceIn(50, 300)
        webView?.settings?.textZoom = textZoomOverride ?: engine.settings.textZoom
    }

    fun setVisible(visible: Boolean) {
        val view = webView ?: return
        if (visible) view.onResume() else view.onPause()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            view.setRendererPriorityPolicy(
                if (visible) WebView.RENDERER_PRIORITY_IMPORTANT else WebView.RENDERER_PRIORITY_WAIVED,
                !visible,
            )
        }
    }

    /** Saves navigation state in memory and releases the WebView. */
    fun suspend() {
        val view = webView ?: return
        lastKnownUrl = view.url ?: lastKnownUrl
        val bundle = Bundle()
        savedState = if (view.saveState(bundle) != null) bundle else null
        destroyView(view)
    }

    fun destroy() {
        webView?.let(::destroyView)
        savedState = null
        pendingUrl = null
    }

    private fun destroyView(view: WebView) {
        webView = null
        (view.parent as? ViewGroup)?.removeView(view)
        view.stopLoading()
        view.setDownloadListener(null)
        view.setFindListener(null)
        view.setOnLongClickListener(null)
        view.webChromeClient = null
        view.loadUrl("about:blank")
        view.onPause()
        view.removeAllViews()
        view.destroy()
    }

    /**
     * Long-press on a link or image opens the browser's context menu. Other
     * long-presses fall through to WebView (text selection, copy/paste).
     */
    private fun emitContextMenu(view: WebView): Boolean {
        val hit = view.hitTestResult
        val extra = hit.extra ?: return false
        if (extra.startsWith("data:") && extra.length > 4096) return false
        return when (hit.type) {
            WebView.HitTestResult.SRC_ANCHOR_TYPE -> {
                engine.emit(id, "contextMenu", mapOf("linkUrl" to extra))
                true
            }
            WebView.HitTestResult.IMAGE_TYPE -> {
                engine.emit(id, "contextMenu", mapOf("imageUrl" to extra))
                true
            }
            WebView.HitTestResult.SRC_IMAGE_ANCHOR_TYPE -> {
                // The link target of an image link comes back asynchronously.
                val message = linkHandler.obtainMessage()
                message.obj = extra
                view.requestFocusNodeHref(message)
                true
            }
            else -> false
        }
    }

    private val linkHandler = object : android.os.Handler(android.os.Looper.getMainLooper()) {
        override fun handleMessage(msg: Message) {
            val imageUrl = msg.obj as? String
            val linkUrl = msg.data?.getString("url")?.takeIf { it.isNotEmpty() }
            engine.emit(id, "contextMenu", mapOf("linkUrl" to linkUrl, "imageUrl" to imageUrl))
        }
    }

    /**
     * Receives sign-in submissions from the page script through an
     * origin-verified WebMessageListener. The browser supplies the sender's
     * origin, so a page can only report credentials for its own origin; the
     * Dart side then asks the user "Save password?" before storing anything.
     */
    private fun installCredentialListener(view: WebView) {
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) return
        WebViewCompat.addWebMessageListener(view, CREDENTIAL_OBJECT, setOf("*")) { _, message, sourceOrigin, isMainFrame, _ ->
            if (!isMainFrame || !engine.settings.capturePasswords) return@addWebMessageListener
            val origin = UrlOrigins.originOf(sourceOrigin.toString()) ?: return@addWebMessageListener
            val data = message.data ?: return@addWebMessageListener
            val json = try {
                JSONObject(data)
            } catch (e: org.json.JSONException) {
                return@addWebMessageListener
            }
            val password = json.optString("p")
            if (password.isEmpty() || password.length > 512) return@addWebMessageListener
            engine.emit(
                id,
                "credentialSubmitted",
                mapOf("origin" to origin, "username" to json.optString("u").take(256), "password" to password),
            )
        }
    }

    private fun injectCredentialCapture(view: WebView) {
        if (incognito || !engine.settings.capturePasswords) return
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) return
        val url = view.url ?: return
        if (UrlOrigins.originOf(url) == null) return
        view.evaluateJavascript(CAPTURE_SCRIPT, null)
    }

    fun navigationState(): Map<String, Any?> {
        val view = webView
        return mapOf(
            "url" to (view?.url ?: lastKnownUrl),
            "title" to view?.title,
            "canGoBack" to (view?.canGoBack() ?: false),
            "canGoForward" to (view?.canGoForward() ?: false),
            "alive" to (view != null),
        )
    }

    fun captureThumbnail(maxWidth: Int): ByteArray? {
        val view = webView ?: return null
        val width = view.width
        val height = view.height
        if (width <= 0 || height <= 0) return null
        val scale = (maxWidth.toFloat() / width).coerceAtMost(1f)
        val bitmap = Bitmap.createBitmap(
            (width * scale).toInt().coerceAtLeast(1),
            (height * scale).toInt().coerceAtLeast(1),
            Bitmap.Config.RGB_565,
        )
        return try {
            val canvas = Canvas(bitmap)
            canvas.scale(scale, scale)
            canvas.translate(-view.scrollX.toFloat(), -view.scrollY.toFloat())
            view.draw(canvas)
            val out = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.JPEG, 70, out)
            out.toByteArray()
        } catch (e: RuntimeException) {
            null
        } finally {
            bitmap.recycle()
        }
    }

    /**
     * Fills the first visible login form on the page. The credential is only
     * injected when the current top-level origin equals [origin]; nothing is
     * exposed to the page through a JavaScript bridge.
     */
    fun fillCredential(origin: String, username: String, password: String, result: (String) -> Unit) {
        val view = webView ?: return result("no_page")
        val current = view.url?.let(UrlOrigins::originOf)
        if (current == null || current != UrlOrigins.normalizeOrigin(origin)) {
            return result("origin_mismatch")
        }
        val script = FILL_SCRIPT
            .replace("__USER__", JSONObject.quote(username))
            .replace("__PASS__", JSONObject.quote(password))
        view.evaluateJavascript(script) { value ->
            result(value?.trim('"') ?: "error")
        }
    }

    /** Reads a blob: URL owned by the current page with a synchronous XHR. */
    fun readBlob(blobUrl: String, result: (String?) -> Unit) {
        val view = webView ?: return result(null)
        val script = BLOB_SCRIPT.replace("__URL__", JSONObject.quote(blobUrl))
        view.evaluateJavascript(script) { value ->
            if (value == null || value == "null") {
                result(null)
            } else {
                result(value.trim('"'))
            }
        }
    }

    private fun isMainFrameUrl(url: String?): Boolean {
        if (url == null) return false
        fun norm(s: String?) = s?.trimEnd('/')
        return norm(url) == norm(lastMainFrameUrl) || norm(url) == norm(webView?.url)
    }

    private inner class Client : WebViewClient() {
        override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
            if (!request.isForMainFrame) return false
            val uri = request.url
            val url = uri.toString()
            return when (uri.scheme?.lowercase()) {
                "https", "about", "data", "blob", "javascript" -> {
                    lastMainFrameUrl = url
                    false
                }
                "http" -> {
                    if (engine.settings.httpsFirst && !engine.isHttpAllowed(uri.host)) {
                        engine.emit(id, "insecureNavigation", mapOf("url" to url))
                        true
                    } else {
                        lastMainFrameUrl = url
                        false
                    }
                }
                "file", "content" -> true // never let pages open local files
                else -> {
                    val fallback = if (uri.scheme == "intent") intentFallbackUrl(url) else null
                    engine.emit(
                        id,
                        "externalApp",
                        mapOf(
                            "url" to url,
                            "fallbackUrl" to fallback,
                            "userGesture" to request.hasGesture(),
                        ),
                    )
                    true
                }
            }
        }

        override fun onPageStarted(view: WebView, url: String?, favicon: Bitmap?) {
            lastKnownUrl = url ?: lastKnownUrl
            lastMainFrameUrl = url
            engine.emit(
                id,
                "pageStarted",
                mapOf(
                    "url" to url,
                    "canGoBack" to view.canGoBack(),
                    "canGoForward" to view.canGoForward(),
                ),
            )
        }

        override fun onPageFinished(view: WebView, url: String?) {
            lastKnownUrl = url ?: lastKnownUrl
            injectCredentialCapture(view)
            engine.emit(
                id,
                "pageFinished",
                mapOf(
                    "url" to url,
                    "title" to view.title,
                    "canGoBack" to view.canGoBack(),
                    "canGoForward" to view.canGoForward(),
                ),
            )
        }

        override fun doUpdateVisitedHistory(view: WebView, url: String?, isReload: Boolean) {
            lastKnownUrl = url ?: lastKnownUrl
            engine.emit(
                id,
                "urlChanged",
                mapOf(
                    "url" to url,
                    "isReload" to isReload,
                    "canGoBack" to view.canGoBack(),
                    "canGoForward" to view.canGoForward(),
                ),
            )
        }

        override fun onReceivedError(
            view: WebView,
            request: WebResourceRequest,
            error: WebResourceError,
        ) {
            if (!request.isForMainFrame) return
            engine.emit(
                id,
                "error",
                mapOf(
                    "url" to request.url.toString(),
                    "code" to error.errorCode,
                    "description" to error.description?.toString(),
                    "online" to engine.isOnline(),
                ),
            )
        }

        override fun onReceivedHttpError(
            view: WebView,
            request: WebResourceRequest,
            errorResponse: WebResourceResponse,
        ) {
            if (!request.isForMainFrame) return
            val headers = errorResponse.responseHeaders ?: emptyMap()
            val proxyError = headers.entries
                .firstOrNull { it.key.equals(PROXY_ERROR_HEADER, ignoreCase = true) }?.value
            engine.emit(
                id,
                "httpError",
                mapOf(
                    "url" to request.url.toString(),
                    "status" to errorResponse.statusCode,
                    "proxyError" to proxyError,
                ),
            )
        }

        @SuppressLint("WebViewClientOnReceivedSslError")
        override fun onReceivedSslError(view: WebView, handler: SslErrorHandler, error: SslError) {
            // Certificate errors are never bypassed.
            handler.cancel()
            if (isMainFrameUrl(error.url)) {
                engine.emit(
                    id,
                    "sslError",
                    mapOf("url" to error.url, "primaryError" to error.primaryError),
                )
            }
        }

        override fun onReceivedHttpAuthRequest(
            view: WebView,
            handler: HttpAuthHandler,
            host: String?,
            realm: String?,
        ) {
            val requestId = engine.pending.addHttpAuth(handler)
            engine.emit(
                id,
                "httpAuthRequest",
                mapOf(
                    "requestId" to requestId,
                    "host" to host,
                    "realm" to realm,
                    "isProxy" to engine.isSystemProxyHost(host),
                    // False after a rejected attempt, so saved credentials are not retried in a loop.
                    "firstAttempt" to handler.useHttpAuthUsernamePassword(),
                    "pageUrl" to view.url,
                ),
            )
        }

        override fun onRenderProcessGone(view: WebView, detail: RenderProcessGoneDetail): Boolean {
            val crashed = detail.didCrash()
            lastKnownUrl = view.url ?: lastKnownUrl
            savedState = null
            destroyView(view)
            engine.emit(id, "rendererGone", mapOf("crashed" to crashed, "url" to lastKnownUrl))
            return true
        }
    }

    private inner class ChromeClient : WebChromeClient() {
        override fun onProgressChanged(view: WebView, newProgress: Int) {
            engine.emit(id, "progress", mapOf("value" to newProgress))
        }

        override fun onReceivedTitle(view: WebView, title: String?) {
            engine.emit(id, "title", mapOf("title" to title, "url" to view.url))
        }

        override fun onReceivedIcon(view: WebView, icon: Bitmap?) {
            if (icon == null) return
            val size = 64
            val scaled = Bitmap.createScaledBitmap(icon, size, size, true)
            val out = ByteArrayOutputStream()
            scaled.compress(Bitmap.CompressFormat.PNG, 100, out)
            if (scaled != icon) scaled.recycle()
            engine.emit(id, "favicon", mapOf("bytes" to out.toByteArray(), "url" to view.url))
        }

        override fun onShowFileChooser(
            webView: WebView,
            filePathCallback: ValueCallback<Array<Uri>>,
            fileChooserParams: FileChooserParams,
        ): Boolean {
            val accept = fileChooserParams.acceptTypes
                ?.flatMap { it.split(',') }
                ?.map { it.trim() }
                ?.filter { it.isNotEmpty() }
                ?: emptyList()
            val multiple = fileChooserParams.mode == FileChooserParams.MODE_OPEN_MULTIPLE
            val requestId = engine.pending.addFileChooser(
                PendingFileChooser(filePathCallback, accept, multiple),
            )
            engine.emit(
                id,
                "fileChooser",
                mapOf(
                    "requestId" to requestId,
                    "acceptTypes" to accept,
                    "multiple" to multiple,
                    "capture" to fileChooserParams.isCaptureEnabled,
                ),
            )
            return true
        }

        override fun onPermissionRequest(request: PermissionRequest) {
            val resources = request.resources.mapNotNull {
                when (it) {
                    PermissionRequest.RESOURCE_VIDEO_CAPTURE -> "camera"
                    PermissionRequest.RESOURCE_AUDIO_CAPTURE -> "microphone"
                    PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID -> "protectedMedia"
                    else -> null
                }
            }
            if (resources.isEmpty()) {
                request.deny()
                return
            }
            val requestId = engine.pending.addPermission(request)
            engine.emit(
                id,
                "permissionRequest",
                mapOf(
                    "requestId" to requestId,
                    "origin" to request.origin.toString(),
                    "resources" to resources,
                ),
            )
        }

        override fun onPermissionRequestCanceled(request: PermissionRequest) {
            val requestId = engine.pending.removePermission(request) ?: return
            engine.emit(id, "permissionCanceled", mapOf("requestId" to requestId))
        }

        override fun onGeolocationPermissionsShowPrompt(
            origin: String,
            callback: GeolocationPermissions.Callback,
        ) {
            val requestId = engine.pending.addGeolocation(PendingGeolocation(origin, callback))
            engine.emit(
                id,
                "permissionRequest",
                mapOf(
                    "requestId" to requestId,
                    "origin" to origin,
                    "resources" to listOf("location"),
                ),
            )
        }

        override fun onGeolocationPermissionsHidePrompt() {
            engine.pending.clearGeolocation()?.let {
                engine.emit(id, "permissionCanceled", mapOf("requestId" to it))
            }
        }

        override fun onShowCustomView(view: View, callback: CustomViewCallback) {
            engine.host.enterFullscreen(view, callback)
            engine.emit(id, "fullscreen", mapOf("active" to true))
        }

        override fun onHideCustomView() {
            if (engine.host.exitFullscreen(notifyPage = false)) {
                engine.emit(id, "fullscreen", mapOf("active" to false))
            }
        }

        override fun onCreateWindow(
            view: WebView,
            isDialog: Boolean,
            isUserGesture: Boolean,
            resultMsg: Message,
        ): Boolean {
            if (!isUserGesture && engine.settings.blockPopups) {
                engine.emit(id, "popupBlocked", mapOf("pageUrl" to view.url))
                return false
            }
            val child = engine.createPopupTab(parent = this@BrowserTab)
            val transport = resultMsg.obj as? WebView.WebViewTransport ?: return false
            transport.webView = child.createForPopup()
            resultMsg.sendToTarget()
            engine.emit(
                child.id,
                "newTab",
                mapOf("parentId" to id, "incognito" to incognito),
            )
            return true
        }

        override fun onCloseWindow(window: WebView) {
            engine.emit(id, "closeRequested", emptyMap())
        }

        override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean = true
    }

    private fun intentFallbackUrl(url: String): String? = try {
        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
        intent.getStringExtra("browser_fallback_url")?.takeIf {
            it.startsWith("https://") || it.startsWith("http://")
        }
    } catch (e: Exception) {
        null
    }

    companion object {
        const val PROXY_ERROR_HEADER = "X-Trex-Proxy-Error"
        private const val CREDENTIAL_OBJECT = "trexCredentials"

        private const val CAPTURE_SCRIPT = """
(function() {
  if (window.__trexCapture || !window.trexCredentials) return;
  window.__trexCapture = true;
  var last = '', lastAt = 0;
  function visible(e) { return !!(e.offsetWidth || e.offsetHeight || e.getClientRects().length); }
  function grab(scope) {
    var root = scope && scope.querySelectorAll ? scope : document;
    var fields = Array.prototype.slice.call(root.querySelectorAll('input[type=password]'))
      .filter(function(e) { return e.value && visible(e); });
    if (!fields.length) return;
    var pw = fields[0];
    var inputs = Array.prototype.slice.call((pw.form || document).querySelectorAll('input')).filter(visible);
    var user = '';
    for (var i = inputs.indexOf(pw) - 1; i >= 0; i--) {
      var t = (inputs[i].getAttribute('type') || 'text').toLowerCase();
      if ((t === 'text' || t === 'email' || t === 'tel') && inputs[i].value) { user = inputs[i].value; break; }
    }
    var msg = JSON.stringify({ u: user, p: pw.value });
    var now = Date.now();
    if (msg === last && now - lastAt < 5000) return;
    last = msg; lastAt = now;
    try { window.trexCredentials.postMessage(msg); } catch (e) {}
  }
  document.addEventListener('submit', function(e) { grab(e.target); }, true);
  document.addEventListener('click', function(e) {
    var b = e.target && e.target.closest && e.target.closest('button, input[type=submit], [role=button]');
    if (b) grab(b.form || document);
  }, true);
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && e.target && e.target.type === 'password') grab(e.target.form || document);
  }, true);
})();
"""

        private const val FILL_SCRIPT = """
(function(u, p) {
  function visible(e) { return !!(e.offsetWidth || e.offsetHeight || e.getClientRects().length); }
  var pw = Array.prototype.slice.call(document.querySelectorAll('input[type=password]')).filter(visible);
  if (!pw.length) return 'no_field';
  var field = pw[0];
  var scope = field.form || document;
  var inputs = Array.prototype.slice.call(scope.querySelectorAll('input')).filter(visible);
  var index = inputs.indexOf(field);
  var user = null;
  for (var i = index - 1; i >= 0; i--) {
    var t = (inputs[i].getAttribute('type') || 'text').toLowerCase();
    if (t === 'text' || t === 'email' || t === 'tel') { user = inputs[i]; break; }
  }
  function set(el, v) {
    var d = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value');
    d.set.call(el, v);
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
  }
  if (user && u) set(user, u);
  set(field, p);
  return 'ok';
})(__USER__, __PASS__);
"""

        private const val BLOB_SCRIPT = """
(function(url) {
  try {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, false);
    xhr.overrideMimeType('text/plain; charset=x-user-defined');
    xhr.send();
    if (xhr.status !== 200 && xhr.status !== 0) return null;
    var raw = xhr.responseText;
    if (raw.length > 52428800) return null;
    var chunks = [];
    for (var i = 0; i < raw.length; i += 32768) {
      var part = raw.substring(i, i + 32768);
      var bytes = new Array(part.length);
      for (var j = 0; j < part.length; j++) bytes[j] = part.charCodeAt(j) & 0xff;
      chunks.push(String.fromCharCode.apply(null, bytes));
    }
    return btoa(chunks.join(''));
  } catch (e) { return null; }
})(__URL__);
"""
    }
}
