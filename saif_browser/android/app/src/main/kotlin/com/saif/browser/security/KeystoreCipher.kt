package com.saif.browser.security

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/**
 * AES-256-GCM (authenticated encryption) with a non-exportable key that lives
 * in the Android Keystore. Ciphertext layout: version(1) | iv(12) | data+tag.
 * Associated data binds each ciphertext to its record so blobs cannot be
 * swapped between rows.
 */
object KeystoreCipher {
    private const val KEYSTORE = "AndroidKeyStore"
    private const val ALIAS = "saif_browser_vault_v1"
    private const val TRANSFORMATION = "AES/GCM/NoPadding"
    private const val VERSION: Byte = 1
    private const val IV_LENGTH = 12
    private const val TAG_BITS = 128

    @Synchronized
    private fun key(): SecretKey {
        val store = KeyStore.getInstance(KEYSTORE).apply { load(null) }
        (store.getKey(ALIAS, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)
        generator.init(
            KeyGenParameterSpec.Builder(
                ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .setRandomizedEncryptionRequired(true)
                .build(),
        )
        return generator.generateKey()
    }

    fun encrypt(plain: ByteArray, associatedData: ByteArray): ByteArray {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, key())
        cipher.updateAAD(associatedData)
        val iv = cipher.iv
        require(iv.size == IV_LENGTH) { "Unexpected IV length" }
        val body = cipher.doFinal(plain)
        val out = ByteArray(1 + IV_LENGTH + body.size)
        out[0] = VERSION
        System.arraycopy(iv, 0, out, 1, IV_LENGTH)
        System.arraycopy(body, 0, out, 1 + IV_LENGTH, body.size)
        return out
    }

    fun decrypt(blob: ByteArray, associatedData: ByteArray): ByteArray {
        require(blob.size > 1 + IV_LENGTH && blob[0] == VERSION) { "Unsupported ciphertext" }
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(
            Cipher.DECRYPT_MODE,
            key(),
            GCMParameterSpec(TAG_BITS, blob, 1, IV_LENGTH),
        )
        cipher.updateAAD(associatedData)
        return cipher.doFinal(blob, 1 + IV_LENGTH, blob.size - 1 - IV_LENGTH)
    }
}
