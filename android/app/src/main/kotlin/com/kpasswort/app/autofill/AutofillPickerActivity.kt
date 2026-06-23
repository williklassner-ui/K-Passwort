package com.kpasswort.app.autofill

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.service.autofill.Dataset
import android.view.autofill.AutofillId
import android.view.autofill.AutofillManager
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AutofillPickerActivity : FlutterActivity() {

    companion object {
        const val EXTRA_USERNAME_ID = "username_autofill_id"
        const val EXTRA_PASSWORD_ID = "password_autofill_id"
        const val EXTRA_DOMAIN = "domain"
        const val EXTRA_PACKAGE = "package_name"
    }

    private val channel by lazy {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "com.kpasswort/autofill_picker")
    }

    override fun getDartEntrypointFunctionName() = "autofillMain"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val domain = intent.getStringExtra(EXTRA_DOMAIN)
        val packageName = intent.getStringExtra(EXTRA_PACKAGE)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getContext" -> result.success(mapOf("domain" to domain, "package" to packageName))
                "fillCredentials" -> {
                    val username = call.argument<String>("username")
                    val password = call.argument<String>("password")
                    returnAutofillResult(username, password)
                    result.success(null)
                }
                "cancel" -> {
                    setResult(Activity.RESULT_CANCELED)
                    finish()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun returnAutofillResult(username: String?, password: String?) {
        val usernameId = intent.getParcelableExtra<AutofillId>(EXTRA_USERNAME_ID)
        val passwordId = intent.getParcelableExtra<AutofillId>(EXTRA_PASSWORD_ID)

        val presentation = RemoteViews(packageName, android.R.layout.simple_list_item_1)
        presentation.setTextViewText(android.R.id.text1, "K-Passwort")

        val dataset = Dataset.Builder().apply {
            if (usernameId != null && username != null)
                setValue(usernameId, AutofillValue.forText(username), presentation)
            if (passwordId != null && password != null)
                setValue(passwordId, AutofillValue.forText(password), presentation)
        }.build()

        val replyIntent = Intent().apply {
            putExtra(AutofillManager.EXTRA_AUTHENTICATION_RESULT, dataset)
        }
        setResult(Activity.RESULT_OK, replyIntent)
        finish()
    }
}
