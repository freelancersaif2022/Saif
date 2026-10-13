package com.saif.browser.security

import androidx.test.ext.junit.runners.AndroidJUnit4
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Test
import org.junit.runner.RunWith
import javax.crypto.AEADBadTagException

/** Runs on a device: the key lives in the hardware-backed Android Keystore. */
@RunWith(AndroidJUnit4::class)
class KeystoreCipherTest {
    private val aad = "credential|https://example.com|alice".toByteArray()

    @Test
    fun roundTrip() {
        val plain = "correct horse battery staple".toByteArray()
        val blob = KeystoreCipher.encrypt(plain, aad)
        assertFalse(String(blob, Charsets.ISO_8859_1).contains("horse"))
        assertArrayEquals(plain, KeystoreCipher.decrypt(blob, aad))
    }

    @Test
    fun freshIvEveryTime() {
        val plain = "same".toByteArray()
        assertNotEquals(KeystoreCipher.encrypt(plain, aad).toList(), KeystoreCipher.encrypt(plain, aad).toList())
    }

    @Test(expected = AEADBadTagException::class)
    fun wrongAssociatedDataFails() {
        val blob = KeystoreCipher.encrypt("secret".toByteArray(), aad)
        KeystoreCipher.decrypt(blob, "credential|https://evil.test|alice".toByteArray())
    }

    @Test(expected = AEADBadTagException::class)
    fun tamperedCiphertextFails() {
        val blob = KeystoreCipher.encrypt("secret".toByteArray(), aad)
        blob[blob.size - 1] = (blob[blob.size - 1].toInt() xor 1).toByte()
        KeystoreCipher.decrypt(blob, aad)
    }
}
