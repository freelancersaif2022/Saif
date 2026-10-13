package com.saif.browser.engine

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.webkit.CookieManager
import android.webkit.GeolocationPermissions
import android.webkit.PermissionRequest
import android.webkit.WebSettings
import android.webkit.WebView
import android.webkit.WebViewDatabase
import androidx.webkit.ProxyConfig
import androidx.webkit.ProxyController
import androidx.webkit.WebViewFeature
import com.saif.browser.system.ActivityHost
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import java.util.concurrent.Executor

/**
 * Native side of the browser engine. Owns every tab's WebView and forwards
 * WebView callbacks to Dart over the `saif/engine` method channel.
 */
class BrowserEngine(
    val context: Context,
    messenger: BinaryMessenger,
    val host: ActivityHost,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, CHANNEL)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val mainExecutor = Executor { mainHandler.post(it) }
    private val tabs = LinkedHashMap<String, BrowserTab>()
    private val allowedHttpHosts = HashSet<String>()
    private val fileChooser = FileChooserLauncher(context, host)

    val pending = PendingRequests()
    val profiles = ProfileSupport()
    var settings = EngineSettings()
        private set

    init {
        channel.setMethodCallHandler(this)
        try {
            profiles.cleanupStaleProfiles()
        } catch (e: RuntimeException) {
            // WebView provider unavailable; reported to Dart through `init`.
        }
    }

    fun tab(id: String): BrowserTab? = tabs[id]

    fun emit(tabId: String, type: String, data: Map<String, Any?>) {
        val payload = HashMap<String, Any?>(data)
        payload["tabId"] = tabId
        payload["type"] = type
        channel.invokeMethod("onEvent", payload)
    }

    fun isHttpAllowed(host: String?): Boolean =
        host != null && allowedHttpHosts.contains(host.lowercase())

    fun isOnline(): Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as? ConnectivityManager
            ?: return true
        val network = cm.activeNetwork ?: return false
        val caps = cm.getNetworkCapabilities(network) ?: return false
        return caps.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
    }

    fun createPopupTab(parent: BrowserTab): BrowserTab {
        val id = "popup-" + UUID.randomUUID().toString()
        val tab = BrowserTab(id, parent.incognito, this)
        tabs[id] = tab
        return tab
    }

    fun onHostVisible(visible: Boolean) {
        val anyView = tabs.values.firstNotNullOfOrNull { it.webView } ?: return
        if (visible) anyView.resumeTimers() else anyView.pauseTimers()
        if (!visible) CookieManager.getInstance().flush()
    }

    fun dispose(finishing: Boolean) {
        channel.setMethodCallHandler(null)
        pending.cancelAll()
        CookieManager.getInstance().flush()
        tabs.values.forEach { it.destroy() }
        tabs.clear()
        if (finishing) profiles.endIncognitoSession()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            handle(call, result)
        } catch (e: IllegalArgumentException) {
            result.error("bad_args", e.message, null)
        } catch (e: IllegalStateException) {
            result.error("bad_state", e.message, null)
        } catch (e: UnsupportedOperationException) {
            result.error("unsupported", e.message, null)
        }
    }

    private fun MethodCall.tabId(): String =
        argument<String>("tabId") ?: throw IllegalArgumentException("tabId missing")

    private fun MethodCall.requireTab(): BrowserTab =
        tabs[tabId()] ?: throw IllegalStateException("Unknown tab")

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> result.success(initInfo())
            "applySettings" -> {
                settings = EngineSettings.fromMap(call.arguments as? Map<*, *>)
                val cookies = CookieManager.getInstance()
                cookies.setAcceptCookie(settings.acceptCookies)
                tabs.values.forEach { it.applySettings(settings) }
                result.success(null)
            }
            "createTab" -> {
                val id = call.tabId()
                val tab = tabs[id] ?: BrowserTab(id, call.argument<Boolean>("incognito") == true, this)
                    .also { tabs[id] = it }
                call.argument<Boolean>("desktopMode")?.let { tab.setDesktopMode(it, reload = false) }
                call.argument<String>("url")?.let {
                    tab.loadUrl(it)
                    // Background tabs start loading right away, like a desktop browser.
                    tab.obtainWebView()
                }
                result.success(null)
            }
            "disposeTab" -> {
                tabs.remove(call.tabId())?.destroy()
                result.success(null)
            }
            "suspendTab" -> {
                tabs[call.tabId()]?.suspend()
                result.success(null)
            }
            "setTabVisible" -> {
                tabs[call.tabId()]?.setVisible(call.argument<Boolean>("visible") == true)
                result.success(null)
            }
            "loadUrl" -> {
                call.requireTab().loadUrl(call.argument<String>("url") ?: "about:blank")
                result.success(null)
            }
            "goBack" -> {
                call.requireTab().webView?.let { if (it.canGoBack()) it.goBack() }
                result.success(null)
            }
            "goForward" -> {
                call.requireTab().webView?.let { if (it.canGoForward()) it.goForward() }
                result.success(null)
            }
            "reload" -> {
                val tab = call.requireTab()
                val view = tab.webView
                if (view != null) view.reload() else tab.obtainWebView()
                result.success(null)
            }
            "stop" -> {
                call.requireTab().webView?.stopLoading()
                result.success(null)
            }
            "navigationState" -> result.success(tabs[call.tabId()]?.navigationState())
            "setDesktopMode" -> {
                call.requireTab().setDesktopMode(call.argument<Boolean>("enabled") == true, reload = true)
                result.success(null)
            }
            "setTextZoom" -> {
                call.requireTab().setTextZoom(call.argument<Int>("percent"))
                result.success(null)
            }
            "find" -> {
                call.requireTab().webView?.findAllAsync(call.argument<String>("query") ?: "")
                result.success(null)
            }
            "findNext" -> {
                call.requireTab().webView?.findNext(call.argument<Boolean>("forward") != false)
                result.success(null)
            }
            "clearFind" -> {
                tabs[call.tabId()]?.webView?.clearMatches()
                result.success(null)
            }
            "captureThumbnail" -> result.success(
                tabs[call.tabId()]?.captureThumbnail(call.argument<Int>("maxWidth") ?: 360),
            )
            "fillCredential" -> {
                call.requireTab().fillCredential(
                    call.argument<String>("origin") ?: "",
                    call.argument<String>("username") ?: "",
                    call.argument<String>("password") ?: "",
                ) { status -> result.success(status) }
            }
            "readBlob" -> {
                call.requireTab().readBlob(call.argument<String>("url") ?: "") { base64 ->
                    result.success(base64)
                }
            }
            "allowHttpHost" -> {
                call.argument<String>("host")?.lowercase()?.let(allowedHttpHosts::add)
                result.success(null)
            }
            "exitFullscreen" -> result.success(host.exitFullscreen())
            "respondFileChooser" -> respondFileChooser(call, result)
            "respondPermission" -> {
                respondPermission(call)
                result.success(null)
            }
            "respondHttpAuth" -> {
                val handler = pending.takeHttpAuth(call.argument<Int>("requestId") ?: -1)
                val user = call.argument<String>("username")
                val pass = call.argument<String>("password")
                if (handler != null) {
                    if (user != null && pass != null) handler.proceed(user, pass) else handler.cancel()
                }
                result.success(null)
            }
            "requestAndroidPermissions" -> {
                val names = (call.argument<List<String>>("permissions") ?: emptyList()).mapNotNull {
                    when (it) {
                        "camera" -> Manifest.permission.CAMERA
                        "microphone" -> Manifest.permission.RECORD_AUDIO
                        "location" -> Manifest.permission.ACCESS_FINE_LOCATION
                        else -> null
                    }
                }
                host.requestPermissions(names) { granted ->
                    result.success(granted.values.all { it })
                }
            }
            "clearBrowsingData" -> clearBrowsingData(call, result)
            "endIncognitoSession" -> {
                val ids = tabs.values.filter { it.incognito }.map { it.id }
                ids.forEach { tabs.remove(it)?.destroy() }
                result.success(mapOf("isolated" to profiles.endIncognitoSession()))
            }
            "setProxyOverride" -> setProxyOverride(call, result)
            "clearProxyOverride" -> {
                if (!WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
                    result.success(false)
                    return
                }
                ProxyController.getInstance().clearProxyOverride(mainExecutor) {
                    result.success(true)
                }
            }
            "isOnline" -> result.success(isOnline())
            "getCookies" -> {
                val url = call.argument<String>("url") ?: ""
                val manager = profiles.cookieManagerForSession(call.argument<Boolean>("incognito") == true)
                result.success(manager?.getCookie(url))
            }
            else -> result.notImplemented()
        }
    }

    private fun initInfo(): Map<String, Any?> {
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WebView.getCurrentWebViewPackage()
        } else {
            null
        }
        val appVersion = try {
            context.packageManager.getPackageInfo(context.packageName, 0).versionName
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
        return mapOf(
            "defaultUserAgent" to WebSettings.getDefaultUserAgent(context),
            "webViewPackage" to packageInfo?.packageName,
            "webViewVersion" to packageInfo?.versionName,
            "multiProfile" to profiles.isolationSupported,
            "proxyOverride" to WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE),
            "appVersion" to appVersion,
            "sdkInt" to Build.VERSION.SDK_INT,
        )
    }

    private fun respondFileChooser(call: MethodCall, result: MethodChannel.Result) {
        val chooser = pending.takeFileChooser(call.argument<Int>("requestId") ?: -1)
        if (chooser == null) {
            result.success(false)
            return
        }
        val source = call.argument<String>("source")
        if (source == null || source == "cancel") {
            chooser.callback.onReceiveValue(null)
            result.success(true)
            return
        }
        fileChooser.launch(source, chooser) { launched -> result.success(launched) }
    }

    private fun respondPermission(call: MethodCall) {
        val requestId = call.argument<Int>("requestId") ?: -1
        val granted = call.argument<List<String>>("granted") ?: emptyList()
        val remember = call.argument<Boolean>("remember") == true
        pending.takeGeolocation(requestId)?.let { geo ->
            geo.callback.invoke(geo.origin, granted.contains("location"), remember)
            return
        }
        val request = pending.takePermission(requestId) ?: return
        val resources = granted.mapNotNull {
            when (it) {
                "camera" -> PermissionRequest.RESOURCE_VIDEO_CAPTURE
                "microphone" -> PermissionRequest.RESOURCE_AUDIO_CAPTURE
                "protectedMedia" -> PermissionRequest.RESOURCE_PROTECTED_MEDIA_ID
                else -> null
            }
        }.filter { request.resources.contains(it) }
        if (resources.isEmpty()) request.deny() else request.grant(resources.toTypedArray())
    }

    private fun clearBrowsingData(call: MethodCall, result: MethodChannel.Result) {
        val cookies = call.argument<Boolean>("cookies") == true
        val cache = call.argument<Boolean>("cache") == true
        val storage = call.argument<Boolean>("storage") == true
        val auth = call.argument<Boolean>("httpAuth") == true
        val permissions = call.argument<Boolean>("permissions") == true
        if (cache) {
            // The HTTP cache is shared by regular tabs; any regular WebView can clear it.
            val view = tabs.values.firstOrNull { !it.incognito && it.webView != null }?.webView
            if (view != null) {
                view.clearCache(true)
            } else {
                val temp = WebView(host.context)
                temp.clearCache(true)
                temp.destroy()
            }
        }
        if (storage) profiles.clearDefaultProfileStorage()
        if (auth) {
            @Suppress("DEPRECATION")
            WebViewDatabase.getInstance(context).clearHttpAuthUsernamePassword()
        }
        if (permissions) GeolocationPermissions.getInstance().clearAll()
        if (cookies) {
            CookieManager.getInstance().removeAllCookies {
                CookieManager.getInstance().flush()
                result.success(true)
            }
        } else {
            result.success(true)
        }
    }

    private fun setProxyOverride(call: MethodCall, result: MethodChannel.Result) {
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
            result.error("unsupported", "This WebView version cannot route traffic through a proxy", null)
            return
        }
        val proxyUrl = call.argument<String>("proxyUrl")
            ?: throw IllegalArgumentException("proxyUrl missing")
        val config = ProxyConfig.Builder()
            .addProxyRule(proxyUrl)
            .build()
        try {
            ProxyController.getInstance().setProxyOverride(config, mainExecutor) {
                result.success(true)
            }
        } catch (e: IllegalArgumentException) {
            result.error("bad_proxy", e.message, null)
        }
    }

    companion object {
        const val CHANNEL = "saif/engine"
    }
}
