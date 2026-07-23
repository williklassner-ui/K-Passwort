package com.kpasswort.app.storage

import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import androidx.documentfile.provider.DocumentFile
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.PluginRegistry
import java.io.File

class SafPlugin(private val activity: Activity) :
    MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {

    companion object {
        private const val CHANNEL = "com.kpasswort/saf"
        private const val REQUEST_OPEN_FILE = 1001
        private const val REQUEST_CREATE_FILE = 1002
        private const val REQUEST_OPEN_DIR = 1003
        private const val REQUEST_PICK_ANY = 1004
        private const val REQUEST_SAVE_ATT = 1005

        fun register(messenger: BinaryMessenger, activity: Activity): SafPlugin {
            val plugin = SafPlugin(activity)
            MethodChannel(messenger, CHANNEL).setMethodCallHandler(plugin)
            return plugin
        }
    }

    private var pendingResult: MethodChannel.Result? = null
    private var pendingOperation: String? = null
    private var pendingRequestCode: Int = 0
    private var pendingSaveBytes: ByteArray? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pickKdbxFile" -> pickKdbxFile(result)
            "pickAnyFile" -> pickAnyFile(result)
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
            "openAttachment" -> {
                val name = call.argument<String>("name") ?: "attachment"
                val mimeType = call.argument<String>("mimeType") ?: "*/*"
                val bytes = call.argument<ByteArray>("bytes")!!
                openAttachment(name, mimeType, bytes, result)
            }
            "saveAttachment" -> {
                val name = call.argument<String>("name") ?: "attachment"
                val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"
                val bytes = call.argument<ByteArray>("bytes")!!
                saveAttachment(name, mimeType, bytes, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun pickAnyFile(result: MethodChannel.Result) {
        pendingResult = result
        pendingOperation = "pick"
        pendingRequestCode = REQUEST_PICK_ANY
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
        }
        activity.startActivityForResult(intent, REQUEST_PICK_ANY)
    }

    private fun pickKdbxFile(result: MethodChannel.Result) {
        pendingResult = result
        pendingOperation = "pick"
        pendingRequestCode = REQUEST_OPEN_FILE
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
        pendingRequestCode = REQUEST_CREATE_FILE
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

    private fun openAttachment(name: String, mimeType: String, bytes: ByteArray, result: MethodChannel.Result) {
        try {
            val cacheDir = File(activity.cacheDir, "attachments").also { it.mkdirs() }
            // Sanitize the attachment name — it originates from vault entries
            // (possibly a KDBX created by another app) and must never be able to
            // escape the cache directory via path separators or "..".
            val safeName = File(name).name
                .replace(Regex("[/\\\\]"), "_")
                .ifBlank { "attachment" }
            val file = File(cacheDir, safeName)
            if (!file.canonicalPath.startsWith(cacheDir.canonicalPath + File.separator)) {
                result.error("INVALID_NAME", "Ungültiger Dateiname", null)
                return
            }
            file.writeBytes(bytes)
            val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.fileprovider", file)
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mimeType)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            activity.startActivity(Intent.createChooser(intent, name))
            result.success(true)
        } catch (e: Exception) {
            result.error("OPEN_FAILED", e.message, null)
        }
    }

    private fun saveAttachment(name: String, mimeType: String, bytes: ByteArray, result: MethodChannel.Result) {
        pendingResult = result
        pendingRequestCode = REQUEST_SAVE_ATT
        pendingSaveBytes = bytes
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, name)
        }
        activity.startActivityForResult(intent, REQUEST_SAVE_ATT)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_OPEN_FILE && requestCode != REQUEST_CREATE_FILE &&
            requestCode != REQUEST_PICK_ANY && requestCode != REQUEST_SAVE_ATT) return false

        val result = pendingResult ?: return false
        pendingResult = null

        val currentRequestCode = pendingRequestCode
        pendingRequestCode = 0

        if (resultCode == Activity.RESULT_OK) {
            val uri = data?.data
            if (uri != null) {
                try {
                    val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    activity.contentResolver.takePersistableUriPermission(uri, flags)
                } catch (_: Exception) {}

                if (currentRequestCode == REQUEST_PICK_ANY) {
                    val docFile = DocumentFile.fromSingleUri(activity, uri)
                    result.success(mapOf(
                        "uri" to uri.toString(),
                        "name" to (docFile?.name ?: "attachment"),
                        "mimeType" to (activity.contentResolver.getType(uri) ?: "application/octet-stream"),
                    ))
                } else if (currentRequestCode == REQUEST_SAVE_ATT) {
                    val bytes = pendingSaveBytes
                    pendingSaveBytes = null
                    if (bytes != null) {
                        try {
                            activity.contentResolver.openOutputStream(uri)?.use { it.write(bytes) }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("WRITE_FAILED", e.message, null)
                        }
                    } else {
                        result.success(false)
                    }
                } else {
                    result.success(uri.toString())
                }
            } else {
                if (currentRequestCode == REQUEST_SAVE_ATT) {
                    pendingSaveBytes = null
                    result.success(false)
                } else {
                    result.error("NO_URI", "No URI returned", null)
                }
            }
        } else {
            pendingSaveBytes = null
            result.success(null)
        }
        return true
    }
}
