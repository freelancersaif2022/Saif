package com.saif.browser.system

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.os.Build
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.webkit.WebChromeClient
import android.widget.FrameLayout

/**
 * Small bridge between the engine/system channels and the hosting activity:
 * activity results, runtime permissions, full-screen custom views, secure
 * window flag and incoming intents.
 */
class ActivityHost(private val activity: Activity) {
    private var nextRequestCode = 0x5A00
    private val resultCallbacks = HashMap<Int, (Int, Intent?) -> Unit>()
    private val permissionCallbacks = HashMap<Int, (Map<String, Boolean>) -> Unit>()

    private var fullscreenView: View? = null
    private var fullscreenCallback: WebChromeClient.CustomViewCallback? = null
    private var fullscreenContainer: FrameLayout? = null

    private var pendingIntent: Intent? = null
    var intentListener: ((Intent) -> Unit)? = null

    val context: Activity get() = activity

    fun rememberIntent(intent: Intent?) {
        pendingIntent = intent
    }

    /** Returns the launch intent once; later intents arrive through [intentListener]. */
    fun consumeInitialIntent(): Intent? {
        val intent = pendingIntent
        pendingIntent = null
        return intent
    }

    fun deliverNewIntent(intent: Intent) {
        val listener = intentListener
        if (listener != null) listener(intent) else pendingIntent = intent
    }

    fun startForResult(intent: Intent, callback: (Int, Intent?) -> Unit): Boolean {
        val code = nextRequestCode++
        resultCallbacks[code] = callback
        return try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(intent, code)
            true
        } catch (e: ActivityNotFoundException) {
            resultCallbacks.remove(code)
            false
        } catch (e: SecurityException) {
            resultCallbacks.remove(code)
            false
        }
    }

    fun dispatchActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        val callback = resultCallbacks.remove(requestCode) ?: return false
        callback(resultCode, data)
        return true
    }

    fun hasPermission(permission: String): Boolean =
        activity.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    /** Requests the runtime permissions that are not granted yet. */
    fun requestPermissions(permissions: List<String>, callback: (Map<String, Boolean>) -> Unit) {
        val missing = permissions.filterNot(::hasPermission)
        if (missing.isEmpty()) {
            callback(permissions.associateWith { true })
            return
        }
        val code = nextRequestCode++
        permissionCallbacks[code] = { results ->
            callback(permissions.associateWith { results[it] ?: hasPermission(it) })
        }
        activity.requestPermissions(missing.toTypedArray(), code)
    }

    fun dispatchPermissionResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        val callback = permissionCallbacks.remove(requestCode) ?: return false
        val results = HashMap<String, Boolean>()
        permissions.forEachIndexed { index, name ->
            results[name] = grantResults.getOrNull(index) == PackageManager.PERMISSION_GRANTED
        }
        callback(results)
        return true
    }

    fun setSecure(secure: Boolean) {
        if (secure) {
            activity.window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    val isFullscreen: Boolean get() = fullscreenView != null

    fun enterFullscreen(view: View, callback: WebChromeClient.CustomViewCallback) {
        if (fullscreenView != null) {
            callback.onCustomViewHidden()
            return
        }
        val decor = activity.window.decorView as ViewGroup
        val container = FrameLayout(activity).apply {
            setBackgroundColor(Color.BLACK)
            addView(
                view,
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                ),
            )
        }
        decor.addView(
            container,
            FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            ),
        )
        fullscreenView = view
        fullscreenCallback = callback
        fullscreenContainer = container
        setSystemBarsHidden(true)
    }

    /** Leaves full-screen. Returns true if a custom view was showing. */
    fun exitFullscreen(notifyPage: Boolean = true): Boolean {
        val container = fullscreenContainer ?: return false
        (activity.window.decorView as ViewGroup).removeView(container)
        container.removeAllViews()
        val callback = fullscreenCallback
        fullscreenView = null
        fullscreenCallback = null
        fullscreenContainer = null
        setSystemBarsHidden(false)
        if (notifyPage) callback?.onCustomViewHidden()
        return true
    }

    @Suppress("DEPRECATION")
    private fun setSystemBarsHidden(hidden: Boolean) {
        val window = activity.window
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val controller = window.insetsController ?: return
            if (hidden) {
                controller.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                controller.hide(WindowInsets.Type.systemBars())
            } else {
                controller.show(WindowInsets.Type.systemBars())
            }
        } else {
            window.decorView.systemUiVisibility = if (hidden) {
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                    View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                    View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
            } else {
                View.SYSTEM_UI_FLAG_VISIBLE
            }
        }
    }

    fun clear() {
        exitFullscreen(notifyPage = false)
        resultCallbacks.clear()
        permissionCallbacks.clear()
        intentListener = null
    }
}
