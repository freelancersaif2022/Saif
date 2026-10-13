package com.saif.browser.engine

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class EngineSettingsTest {
    @Test
    fun defaultsAreSafe() {
        val s = EngineSettings.fromMap(null)
        assertTrue(s.javaScriptEnabled)
        assertTrue(s.blockPopups)
        assertFalse(s.thirdPartyCookies)
        assertTrue(s.safeBrowsing)
        assertTrue(s.httpsFirst)
        assertEquals(100, s.textZoom)
    }

    @Test
    fun parsesValuesFromDart() {
        val s = EngineSettings.fromMap(
            mapOf(
                "javaScriptEnabled" to false,
                "blockPopups" to false,
                "acceptCookies" to true,
                "thirdPartyCookies" to true,
                "textZoom" to 150,
                "mobileUserAgent" to "UA",
                "desktopUserAgent" to "",
                "safeBrowsing" to false,
                "httpsFirst" to false,
            ),
        )
        assertFalse(s.javaScriptEnabled)
        assertFalse(s.blockPopups)
        assertTrue(s.thirdPartyCookies)
        assertEquals(150, s.textZoom)
        assertEquals("UA", s.mobileUserAgent)
        assertNull("blank user agents fall back to the WebView default", s.desktopUserAgent)
        assertFalse(s.httpsFirst)
    }

    @Test
    fun clampsTextZoom() {
        assertEquals(300, EngineSettings.fromMap(mapOf("textZoom" to 1000)).textZoom)
        assertEquals(50, EngineSettings.fromMap(mapOf("textZoom" to 1)).textZoom)
    }
}
