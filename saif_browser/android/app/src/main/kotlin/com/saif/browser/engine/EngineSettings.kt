package com.saif.browser.engine

/** Browser-wide WebView settings pushed from Dart. */
data class EngineSettings(
    val javaScriptEnabled: Boolean = true,
    val blockPopups: Boolean = true,
    val acceptCookies: Boolean = true,
    val thirdPartyCookies: Boolean = false,
    val textZoom: Int = 100,
    val mobileUserAgent: String? = null,
    val desktopUserAgent: String? = null,
    val safeBrowsing: Boolean = true,
    val httpsFirst: Boolean = true,
    val capturePasswords: Boolean = true,
) {
    companion object {
        fun fromMap(map: Map<*, *>?): EngineSettings {
            if (map == null) return EngineSettings()
            return EngineSettings(
                javaScriptEnabled = map["javaScriptEnabled"] as? Boolean ?: true,
                blockPopups = map["blockPopups"] as? Boolean ?: true,
                acceptCookies = map["acceptCookies"] as? Boolean ?: true,
                thirdPartyCookies = map["thirdPartyCookies"] as? Boolean ?: false,
                textZoom = (map["textZoom"] as? Number)?.toInt()?.coerceIn(50, 300) ?: 100,
                mobileUserAgent = (map["mobileUserAgent"] as? String)?.takeIf { it.isNotBlank() },
                desktopUserAgent = (map["desktopUserAgent"] as? String)?.takeIf { it.isNotBlank() },
                safeBrowsing = map["safeBrowsing"] as? Boolean ?: true,
                httpsFirst = map["httpsFirst"] as? Boolean ?: true,
                capturePasswords = map["capturePasswords"] as? Boolean ?: true,
            )
        }
    }
}
