package com.kpasswort.app.autofill

import android.app.PendingIntent
import android.content.Intent
import android.content.IntentSender
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.Dataset
import android.service.autofill.FillCallback
import android.service.autofill.FillContext
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveRequest
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import android.os.Build

class KPasswortAutofillService : AutofillService() {

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback
    ) {
        val structure = request.fillContexts.lastOrNull()?.structure ?: run {
            callback.onSuccess(null)
            return
        }

        val parser = AutofillParser(structure)
        val fields = parser.parse()

        if (fields.usernameId == null && fields.passwordId == null) {
            callback.onSuccess(null)
            return
        }

        // We always launch the picker (authenticated selection)
        // A production implementation could cache decrypted datasets in memory
        val intentSender = buildPickerIntentSender(fields)

        val presentation = buildPresentation("K-Passwort")

        val dataset = Dataset.Builder()
            .apply {
                fields.usernameId?.let { setValue(it, AutofillValue.forText(""), presentation) }
                fields.passwordId?.let { setValue(it, AutofillValue.forText(""), presentation) }
            }
            .setAuthentication(intentSender)
            .build()

        val response = FillResponse.Builder()
            .addDataset(dataset)
            .build()

        callback.onSuccess(response)
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        // Save new credentials — launch picker activity for save flow
        callback.onSuccess()
    }

    private fun buildPickerIntentSender(fields: AutofillFields): IntentSender {
        val intent = Intent(this, AutofillPickerActivity::class.java).apply {
            putExtra(AutofillPickerActivity.EXTRA_USERNAME_ID, fields.usernameId)
            putExtra(AutofillPickerActivity.EXTRA_PASSWORD_ID, fields.passwordId)
            putExtra(AutofillPickerActivity.EXTRA_DOMAIN, fields.webDomain)
            putExtra(AutofillPickerActivity.EXTRA_PACKAGE, fields.packageName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getActivity(this, 0, intent, flags).intentSender
    }

    private fun buildPresentation(label: String): RemoteViews {
        val presentation = RemoteViews(packageName, android.R.layout.simple_list_item_1)
        presentation.setTextViewText(android.R.id.text1, label)
        return presentation
    }
}
