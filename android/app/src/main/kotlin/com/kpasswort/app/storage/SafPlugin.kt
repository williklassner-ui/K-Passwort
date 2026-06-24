package com.kpasswort.app.storage

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry

class SafPlugin(private val activity: Activity) :
    MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {

    companion object {
        private const val CHANNEL = "com.kpasswort/saf"
        private const val REQUEST_OPEN_FILE = 1001
        private const val REQUEST_CREATE_FILE = 1002
        private const val REQUEST_OPEN_DIR = 1003

        fun register(messenger: BinaryMessenger, activity: Activity): SafPlugin {
            val plugin = SafPlugin(activity)
            MethodChannel(messenger, CHANNEL).setMethodCallHandler(plugin)
            return plugin
        }
    }

    private var pendingResult: MethodChannel.Result? = null
    private var pendingOperation: String? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickKdbxFile" -> pickKdbxFile(result)
            "createKdbxFile" -> {
                val name = call.argument<String>("name") ?: "vault.kdbx"
                createKdbxFile(name, result)
            }
            "readFile" -> {
                val uri = call.argument<String>("uri")!!
                result.success(readFile(uri))
            }
            "writeFile" -> {
                val uri = call.argument<String>("uri")!!
                val bytes = call.argument<ByteArray>("bytes")!!
                writeFile(uri, bytes, result)
            }
            "getFileInfo" -> {
                val uri = call.argument<String>("uri")!!
                result.success(getFileInfo(uri))
            }
            "takePersistablePermission" -> {
                val uri = call.argument<String>("uri")!!
                takePersistablePermission(uri, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun pickKdbxFile(result: MethodChannel.Result) {
        pendingResult = result
        pendingOperation = "pick"
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(Intent.EXTRA_MIME_TYPES, arrayOf(
                "application/octet-stream",
                "application/x-keepass",
                "*/*"
            ))
        }
        activity.startActivityForResult(intent, REQUEST_OPEN_FILE)
    }

    private fun createKdbxFile(name: String, result: MethodChannel.Result) {
        pendingResult = result
        pendingOperation = "create"
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/octet-stream"
            putExtra(Intent.EXTRA_TITLE, if (name.endsWith(".kdbx")) name else "$name.kdbx")
        }
        activity.startActivityForResult(intent, REQUEST_CREATE_FILE)
    }

    private fun readFile(uriString: String): ByteArray? {
        return try {
            val uri = Uri.parse(uriString)
            activity.contentResolver.openInputStream(uri)?.use { it.readBytes() }
        } catch (e: Exception) {
            null
        }
    }

    private fun writeFile(uriString: String, bytes: ByteArray, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(uriString)
            activity.contentResolver.openOutputStream(uri, "wt")?.use { stream ->
                stream.write(bytes)
                stream.flush()
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("WRITE_FAILED", e.message, null)
        }
    }

    private fun getFileInfo(uriString: String): Map<String, Any?>? {
        return try {
            val uri = Uri.parse(uriString)
            val docFile = DocumentFile.fromSingleUri(activity, uri) ?: return null
            mapOf(
                "name" to docFile.name,
                "lastModified" to docFile.lastModified(),
                "size" to docFile.length(),
                "exists" to docFile.exists(),
                "canWrite" to docFile.canWrite()
            )
        } catch (e: Exception) {
            null
        }
    }

    private fun takePersistablePermission(uriString: String, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(uriString)
            val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
            activity.contentResolver.takePersistableUriPermission(uri, flags)
            result.success(true)
        } catch (e: Exception) {
            result.error("PERMISSION_FAILED", e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_OPEN_FILE && requestCode != REQUEST_CREATE_FILE) return false

        val result = pendingResult ?: return false
        pendingResult = null

        if (resultCode == Activity.RESULT_OK) {
            val uri = data?.data
            if (uri != null) {
                // Take persistable permission so we can access across restarts
                try {
                    val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    activity.contentResolver.takePersistableUriPermission(uri, flags)
                } catch (_: Exception) {}
                result.success(uri.toString())
            } else {
                result.error("NO_URI", "No URI returned", null)
            }
        } else {
            result.success(null)
        }
        return true
    }
}
