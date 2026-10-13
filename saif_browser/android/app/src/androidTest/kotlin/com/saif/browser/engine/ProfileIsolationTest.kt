package com.saif.browser.engine

import android.webkit.CookieManager
import android.webkit.WebView
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.webkit.ProfileStore
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assume.assumeTrue
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Verifies on a device that a private profile has its own cookie jar and
 * that ending the session does not touch regular cookies.
 */
@RunWith(AndroidJUnit4::class)
class ProfileIsolationTest {
    @Test
    fun privateCookiesAreIsolatedAndRemoved() {
        assumeTrue(WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROFILE))
        InstrumentationRegistry.getInstrumentation().runOnMainSync {
            val context = InstrumentationRegistry.getInstrumentation().targetContext
            val support = ProfileSupport()
            val view = WebView(context)
            support.attachIncognitoProfile(view)
            val privateCookies = WebViewCompat.getProfile(view).cookieManager
            val regular = CookieManager.getInstance()

            regular.setCookie("https://isolation.test", "regular=1")
            privateCookies.setCookie("https://isolation.test", "private=1")
            assertEquals("regular=1", regular.getCookie("https://isolation.test"))
            assertEquals("private=1", privateCookies.getCookie("https://isolation.test"))

            val name = WebViewCompat.getProfile(view).name
            view.destroy()
            support.endIncognitoSession()
            assertNull(ProfileStore.getInstance().getProfile(name)?.cookieManager?.getCookie("https://isolation.test"))
            assertEquals("regular=1", regular.getCookie("https://isolation.test"))
            regular.removeAllCookies(null)
        }
    }
}
