package com.saif.browser.engine

import android.webkit.CookieManager
import android.webkit.WebStorage
import android.webkit.WebView
import androidx.webkit.ProfileStore
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature

/**
 * Private browsing storage isolation.
 *
 * When the installed WebView supports MULTI_PROFILE, every private session
 * gets its own WebView profile (separate cookies, storage, cache, service
 * workers). The profile is wiped and deleted when the session ends and any
 * leftovers are removed on the next launch. Without MULTI_PROFILE, private
 * tabs share storage with regular tabs; [isolationSupported] reports that so
 * the UI can say so instead of claiming isolation.
 */
class ProfileSupport {
    val isolationSupported: Boolean by lazy {
        try {
            WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE)
        } catch (e: Throwable) {
            false
        }
    }

    private var sessionCounter = 0
    private var currentProfile: String? = null

    /** Deletes private profiles left behind by an earlier process. */
    fun cleanupStaleProfiles() {
        if (!isolationSupported) return
        val store = ProfileStore.getInstance()
        store.allProfileNames.filter { it.startsWith(PREFIX) }.forEach { name ->
            wipeProfile(name)
            try {
                store.deleteProfile(name)
            } catch (e: IllegalStateException) {
                // Still in use in this process; it is wiped and retried next launch.
            }
        }
    }

    fun attachIncognitoProfile(view: WebView) {
        if (!isolationSupported) return
        val name = currentProfile ?: "$PREFIX${System.currentTimeMillis()}_${sessionCounter++}".also {
            currentProfile = it
        }
        ProfileStore.getInstance().getOrCreateProfile(name)
        WebViewCompat.setProfile(view, name)
    }

    fun cookieManagerFor(view: WebView, incognito: Boolean): CookieManager {
        if (incognito && isolationSupported) {
            return WebViewCompat.getProfile(view).cookieManager
        }
        return CookieManager.getInstance()
    }

    /** Cookie manager used for downloads started from a tab. */
    fun cookieManagerForSession(incognito: Boolean): CookieManager? {
        if (!incognito) return CookieManager.getInstance()
        if (!isolationSupported) return CookieManager.getInstance()
        val name = currentProfile ?: return null
        return ProfileStore.getInstance().getProfile(name)?.cookieManager
    }

    /**
     * Ends the private session. All private WebViews must already be
     * destroyed. Returns true when the profile data was removed.
     */
    fun endIncognitoSession(): Boolean {
        val name = currentProfile ?: return true
        currentProfile = null
        if (!isolationSupported) return false
        wipeProfile(name)
        return try {
            ProfileStore.getInstance().deleteProfile(name)
        } catch (e: IllegalStateException) {
            // Data has been wiped; the empty profile directory is removed at next launch.
            true
        }
    }

    private fun wipeProfile(name: String) {
        val profile = ProfileStore.getInstance().getProfile(name) ?: return
        profile.cookieManager.removeAllCookies(null)
        profile.cookieManager.flush()
        profile.webStorage.deleteAllData()
        profile.geolocationPermissions.clearAll()
    }

    fun clearDefaultProfileStorage() {
        WebStorage.getInstance().deleteAllData()
    }

    companion object {
        private const val PREFIX = "saif_private_"
    }
}
