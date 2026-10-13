package com.saif.browser.engine

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Embeds an existing tab's WebView into the Flutter view hierarchy. The
 * WebView outlives the platform view, so switching tabs never reloads pages.
 */
class WebViewFactory(private val engine: BrowserEngine) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val tabId = (args as? Map<*, *>)?.get("tabId") as? String
        val container = FrameLayout(context)
        val tab = tabId?.let(engine::tab)
        if (tab != null) {
            val webView = tab.obtainWebView()
            (webView.parent as? ViewGroup)?.removeView(webView)
            container.addView(
                webView,
                FrameLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                ),
            )
            tab.setVisible(true)
        }
        return TabPlatformView(container)
    }

    private class TabPlatformView(private val container: FrameLayout) : PlatformView {
        override fun getView(): View = container

        override fun dispose() {
            // Detach only; the WebView belongs to its tab and stays alive.
            container.removeAllViews()
        }
    }

    companion object {
        const val VIEW_TYPE = "saif/webview"
    }
}
