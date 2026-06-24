package com.kpasswort.app.crypto

import android.content.Context
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class BiometricCryptoHelper(private val activity: FragmentActivity) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.kpasswort/biometric"
        private const val KEY_ALIAS = "kpasswort_master_key_wrap"
        private const val KEYSTORE_PROVIDER = "AndroidKeyStore"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val GCM_TAG_LENGTH = 128

        fun register(messenger: BinaryMessenger, activity: FragmentActivity) {
            val helper = BiometricCryptoHelper(activity)
            MethodChannel(messenger, CHANNEL).setMethodCallHandler(helper)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAvailable" -> result.success(isBiometricAvailable())
            "generateKey" -> generateKey(result)
            "wrapKey" -> {
                val keyBytes = call.argument<ByteArray>("keyBytes")!!
                wrapKey(keyBytes, result)
            }
            "unwrapKey" -> {
                val wrappedKey = call.argument<String>("wrappedKey")!!
                val iv = call.argument<String>("iv")!!
                unwrapKey(wrappedKey, iv, result)
            }
            "deleteKey" -> deleteKey(result)
            else -> result.notImplemented()
        }
    }

    private fun isBiometricAvailable(): Boolean {
        val manager = BiometricManager.from(activity)
        return manager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG
        ) == BiometricManager.BIOMETRIC_SUCCESS
    }

    private fun generateKey(result: MethodChannel.Result) {
        try {
            val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
            keyStore.load(null)

            if (keyStore.containsAlias(KEY_ALIAS)) {
                result.success(true)
                return
            }

            val keyGenerator = KeyGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_AES, KEYSTORE_PROVIDER
            )
            val spec = KeyGenParameterSpec.Builder(
                KEY_ALIAS,
                KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
            )
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .setUserAuthenticationRequired(true)
                .setInvalidatedByBiometricEnrollment(true)
                .build()

            keyGenerator.init(spec)
            keyGenerator.generateKey()
            result.success(true)
        } catch (e: Exception) {
            result.error("KEY_GEN_FAILED", e.message, null)
        }
    }

    private fun getSecretKey(): SecretKey {
        val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
        keyStore.load(null)
        return keyStore.getKey(KEY_ALIAS, null) as SecretKey
    }

    private fun wrapKey(keyBytes: ByteArray, result: MethodChannel.Result) {
        try {
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.ENCRYPT_MODE, getSecretKey())

            val executor = ContextCompat.getMainExecutor(activity)
            val cryptoObject = BiometricPrompt.CryptoObject(cipher)

            val promptInfo = BiometricPrompt.PromptInfo.Builder()
                .setTitle(activity.getString(android.R.string.ok)) // will be set from Flutter
                .setSubtitle("Biometrische Authentifizierung")
                .setNegativeButtonText("Abbrechen")
                .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
                .build()

            val prompt = BiometricPrompt(activity, executor, object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                    try {
                        val authenticatedCipher = authResult.cryptoObject?.cipher!!
                        val encrypted = authenticatedCipher.doFinal(keyBytes)
                        val iv = Base64.encodeToString(authenticatedCipher.iv, Base64.NO_WRAP)
                        val wrapped = Base64.encodeToString(encrypted, Base64.NO_WRAP)
                        result.success(mapOf("wrappedKey" to wrapped, "iv" to iv))
                    } catch (e: Exception) {
                        result.error("WRAP_FAILED", e.message, null)
                    }
                }

                override fun onAuthenticationError(code: Int, message: CharSequence) {
                    result.error("AUTH_ERROR", message.toString(), code)
                }

                override fun onAuthenticationFailed() {
                    result.error("AUTH_FAILED", "Authentication failed", null)
                }
            })
            prompt.authenticate(promptInfo, cryptoObject)
        } catch (e: Exception) {
            result.error("WRAP_INIT_FAILED", e.message, null)
        }
    }

    private fun unwrapKey(wrappedKey: String, ivBase64: String, result: MethodChannel.Result) {
        try {
            val iv = Base64.decode(ivBase64, Base64.NO_WRAP)
            val cipher = Cipher.getInstance(TRANSFORMATION)
            val spec = GCMParameterSpec(GCM_TAG_LENGTH, iv)
            cipher.init(Cipher.DECRYPT_MODE, getSecretKey(), spec)

            val executor = ContextCompat.getMainExecutor(activity)
            val cryptoObject = BiometricPrompt.CryptoObject(cipher)

            val promptInfo = BiometricPrompt.PromptInfo.Builder()
                .setTitle("K-Passwort entsperren")
                .setSubtitle("Biometrische Authentifizierung")
                .setNegativeButtonText("Masterpasswort")
                .setAllowedAuthenticators(BiometricManager.Authenticators.BIOMETRIC_STRONG)
                .build()

            val prompt = BiometricPrompt(activity, executor, object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                    try {
                        val authenticatedCipher = authResult.cryptoObject?.cipher!!
                        val encryptedBytes = Base64.decode(wrappedKey, Base64.NO_WRAP)
                        val decrypted = authenticatedCipher.doFinal(encryptedBytes)
                        result.success(decrypted)
                    } catch (e: Exception) {
                        result.error("UNWRAP_FAILED", e.message, null)
                    }
                }

                override fun onAuthenticationError(code: Int, message: CharSequence) {
                    result.error("AUTH_ERROR", message.toString(), code)
                }

                override fun onAuthenticationFailed() {
                    result.error("AUTH_FAILED", "Authentication failed", null)
                }
            })
            prompt.authenticate(promptInfo, cryptoObject)
        } catch (e: Exception) {
            result.error("UNWRAP_INIT_FAILED", e.message, null)
        }
    }

    private fun deleteKey(result: MethodChannel.Result) {
        try {
            val keyStore = KeyStore.getInstance(KEYSTORE_PROVIDER)
            keyStore.load(null)
            if (keyStore.containsAlias(KEY_ALIAS)) {
                keyStore.deleteEntry(KEY_ALIAS)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("DELETE_FAILED", e.message, null)
        }
    }
}
