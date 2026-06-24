package com.kpasswort.app

import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import com.kpasswort.app.autofill.AutofillBridgePlugin
import com.kpasswort.app.crypto.BiometricCryptoHelper
import com.kpasswort.app.clipboard.SecureClipboardPlugin
import com.kpasswort.app.storage.SafPlugin

class MainActivity : FlutterFragmentActivity() {

    private var safPlugin: SafPlugin? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Block screenshots and screen recording in all states
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE
        )
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        AutofillBridgePlugin.register(messenger, this)
        BiometricCryptoHelper.register(messenger, this)
        SecureClipboardPlugin.register(messenger, this)
        safPlugin = SafPlugin.register(messenger, this)
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
