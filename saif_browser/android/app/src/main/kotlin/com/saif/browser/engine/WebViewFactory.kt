package com.saif.browser.engine

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Creates the single browser surface embedded in Flutter. Switching tabs
 * swaps the WebView inside this container natively, so Flutter never has to
 * tear down and recreate a platform view (no flicker or lag between tabs).
 */
class WebViewFactory(private val engine: BrowserEngine) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val container = FrameLayout(context).apply { setBackgroundColor(Color.WHITE) }
        engine.attachContainer(container)
        return object : PlatformView {
            override fun getView(): View = container

            override fun dispose() {
                engine.detachContainer(container)
            }
        }
    }

    companion object {
        const val VIEW_TYPE = "saif/webview"
    }
}
