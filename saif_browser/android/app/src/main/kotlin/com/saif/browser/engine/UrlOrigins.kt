package com.saif.browser.engine

import android.net.Uri

/** Origin helpers used to bind credentials to the top-level page origin. */
object UrlOrigins {
    fun originOf(url: String): String? {
        val uri = Uri.parse(url)
        val scheme = uri.scheme?.lowercase() ?: return null
        if (scheme != "https" && scheme != "http") return null
        val host = uri.host?.lowercase() ?: return null
        val port = uri.port
        val defaultPort = if (scheme == "https") 443 else 80
        return if (port == -1 || port == defaultPort) "$scheme://$host" else "$scheme://$host:$port"
    }

    fun normalizeOrigin(origin: String): String? = originOf(origin)
}
