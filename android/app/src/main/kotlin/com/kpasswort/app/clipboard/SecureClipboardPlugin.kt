package com.kpasswort.app.clipboard

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger

class SecureClipboardPlugin(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.kpasswort/clipboard"

        fun register(messenger: BinaryMessenger, context: Context) {
            val plugin = SecureClipboardPlugin(context)
            MethodChannel(messenger, CHANNEL).setMethodCallHandler(plugin)
        }
    }

    private val handler = Handler(Looper.getMainLooper())
    private var clearRunnable: Runnable? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "copySecure" -> {
                val text = call.argument<String>("text")!!
                val clearAfterMs = call.argument<Int>("clearAfterMs") ?: 30000
                copySecure(text, clearAfterMs.toLong(), result)
            }
            "clearClipboard" -> {
                clearClipboard()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun copySecure(text: String, clearAfterMs: Long, result: MethodChannel.Result) {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("", text)
        clipboard.setPrimaryClip(clip)

        // Cancel any previously scheduled clear
        clearRunnable?.let { handler.removeCallbacks(it) }

        // Schedule automatic clear
        clearRunnable = Runnable { clearClipboard() }.also {
            handler.postDelayed(it, clearAfterMs)
        }

        result.success(true)
    }

    private fun clearClipboard() {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        // Android 13+: clearPrimaryClip; older: set empty clip
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            clipboard.clearPrimaryClip()
        } else {
            val clip = ClipData.newPlainText("", "")
            clipboard.setPrimaryClip(clip)
        }
        clearRunnable = null
    }
}
