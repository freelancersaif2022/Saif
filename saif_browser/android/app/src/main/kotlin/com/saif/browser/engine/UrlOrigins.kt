package com.saif.browser.engine

import java.net.URI
import java.net.URISyntaxException

/** Origin helpers used to bind credentials to the top-level page origin. */
object UrlOrigins {
    /** Returns `scheme://host[:port]` for http(s) URLs, or null. */
    fun originOf(url: String): String? {
        val uri = try {
            URI(url.trim())
        } catch (e: URISyntaxException) {
            return null
        }
        val scheme = uri.scheme?.lowercase() ?: return null
        if (scheme != "https" && scheme != "http") return null
        val host = uri.host?.lowercase()?.takeIf { it.isNotEmpty() } ?: return null
        val port = uri.port
        val defaultPort = if (scheme == "https") 443 else 80
        return if (port == -1 || port == defaultPort) "$scheme://$host" else "$scheme://$host:$port"
    }

    fun normalizeOrigin(origin: String): String? = originOf(origin)
}
