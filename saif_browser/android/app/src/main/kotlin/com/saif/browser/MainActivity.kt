package com.saif.browser

import android.content.Intent
import android.os.Bundle
import com.saif.browser.engine.BrowserEngine
import com.saif.browser.engine.WebViewFactory
import com.saif.browser.system.ActivityHost
import com.saif.browser.system.SystemChannel
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Hosts the Flutter UI. Extends [FlutterFragmentActivity] because the
 * `local_auth` plugin needs a FragmentActivity for BiometricPrompt.
 */
class MainActivity : FlutterFragmentActivity() {
    private val host = ActivityHost(this)
    private var browserEngine: BrowserEngine? = null
    private var systemChannel: SystemChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        host.rememberIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val engine = BrowserEngine(applicationContext, messenger, host)
        browserEngine = engine
        systemChannel = SystemChannel(applicationContext, messenger, host, engine)
        flutterEngine.platformViewsController.registry
            .registerViewFactory(WebViewFactory.VIEW_TYPE, WebViewFactory(engine))
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        host.deliverNewIntent(intent)
    }

    @Suppress("OVERRIDE_DEPRECATION", "DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (!host.dispatchActivityResult(requestCode, resultCode, data)) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (!host.dispatchPermissionResult(requestCode, permissions, grantResults)) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }
    }

    override fun onStart() {
        super.onStart()
        browserEngine?.onHostVisible(true)
    }

    override fun onStop() {
        browserEngine?.onHostVisible(false)
        super.onStop()
    }

    override fun onDestroy() {
        systemChannel?.dispose()
        browserEngine?.dispose(isFinishing)
        browserEngine = null
        systemChannel = null
        host.clear()
        super.onDestroy()
    }
}
