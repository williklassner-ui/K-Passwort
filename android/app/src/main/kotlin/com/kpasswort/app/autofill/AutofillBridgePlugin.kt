package com.kpasswort.app.autofill

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AutofillBridgePlugin(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.kpasswort/autofill"
        private var channel: MethodChannel? = null

        fun register(messenger: BinaryMessenger, context: Context) {
            val plugin = AutofillBridgePlugin(context)
            channel = MethodChannel(messenger, CHANNEL).also {
                it.setMethodCallHandler(plugin)
            }
        }

        fun notifyBackground(messenger: BinaryMessenger) {
            channel?.invokeMethod("onBackground", null)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isAutofillServiceEnabled" -> {
                // Check if our AutofillService is the current default
                val manager = context.getSystemService(Context.AUTOFILL_MANAGER_CLASS_NAME)
                result.success(false) // Simplified; implement via AutofillManager reflection
            }
            "openAutofillSettings" -> {
                val intent = android.content.Intent(android.provider.Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE)
                intent.data = android.net.Uri.parse("package:${context.packageName}")
                intent.flags = android.content.Intent.FLAG_ACTIVITY_NEW_TASK
                context.startActivity(intent)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }
}
