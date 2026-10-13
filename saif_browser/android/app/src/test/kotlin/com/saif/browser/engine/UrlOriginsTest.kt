package com.saif.browser.engine

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class UrlOriginsTest {
    @Test
    fun normalisesOrigins() {
        assertEquals("https://example.com", UrlOrigins.originOf("https://Example.com/login?x=1"))
        assertEquals("https://example.com", UrlOrigins.originOf("https://example.com:443/"))
        assertEquals("http://example.com:8080", UrlOrigins.originOf("http://example.com:8080/a"))
    }

    @Test
    fun rejectsNonWebUrls() {
        assertNull(UrlOrigins.originOf("javascript:alert(1)"))
        assertNull(UrlOrigins.originOf("file:///sdcard/a.html"))
        assertNull(UrlOrigins.originOf("data:text/html,hi"))
        assertNull(UrlOrigins.originOf("not a url"))
    }

    @Test
    fun credentialsAreBoundToTheExactOrigin() {
        // A look-alike host or a different scheme must not match.
        val saved = UrlOrigins.normalizeOrigin("https://bank.example")
        assert(UrlOrigins.originOf("https://bank.example.evil.test/") != saved)
        assert(UrlOrigins.originOf("http://bank.example/") != saved)
        assertEquals(saved, UrlOrigins.originOf("https://bank.example/account"))
    }
}
