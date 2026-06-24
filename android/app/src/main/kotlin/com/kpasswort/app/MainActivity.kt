package com.kpasswort.app

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.kpasswort.app.autofill.AutofillBridgePlugin
import com.kpasswort.app.crypto.BiometricCryptoHelper
import com.kpasswort.app.clipboard.SecureClipboardPlugin
import com.kpasswort.app.storage.SafPlugin

class MainActivity : FlutterFragmentActivity() {

    private var safPlugin: SafPlugin? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Screenshots allowed by default; user can enable blocking in Settings
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        AutofillBridgePlugin.register(messenger, this)
        BiometricCryptoHelper.register(messenger, this)
        SecureClipboardPlugin.register(messenger, this)
        safPlugin = SafPlugin.register(messenger, this)

        MethodChannel(messenger, "com.kpasswort/secure_screen").setMethodCallHandler { call, result ->
            if (call.method == "setSecureScreen") {
                val enabled = call.argument<Boolean>("enabled") ?: false
                if (enabled) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (safPlugin?.onActivityResult(requestCode, resultCode, data) != true) {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // Notify Flutter that app moved to background (triggers auto-lock timer)
        flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
            AutofillBridgePlugin.notifyBackground(messenger)
        }
    }
}
