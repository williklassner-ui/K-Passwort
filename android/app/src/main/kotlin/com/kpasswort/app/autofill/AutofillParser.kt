package com.kpasswort.app.autofill

import android.app.assist.AssistStructure
import android.text.InputType
import android.view.View
import android.view.autofill.AutofillId

data class AutofillFields(
    val usernameId: AutofillId?,
    val passwordId: AutofillId?,
    val webDomain: String?,
    val packageName: String?
)

class AutofillParser(private val structure: AssistStructure) {

    fun parse(): AutofillFields {
        var usernameId: AutofillId? = null
        var passwordId: AutofillId? = null
        var webDomain: String? = null
        val packageName = structure.activityComponent?.packageName

        for (i in 0 until structure.windowNodeCount) {
            val windowNode = structure.getWindowNodeAt(i)
            val domain = windowNode.title?.toString()?.extractDomain()
            if (domain != null) webDomain = domain

            traverseNode(windowNode.rootViewNode) { node ->
                val domain2 = node.webDomain
                if (!domain2.isNullOrEmpty()) webDomain = domain2

                val hint = node.autofillHints
                if (hint != null) {
                    when {
                        hint.any { isUsernameHint(it) } && usernameId == null ->
                            usernameId = node.autofillId
                        hint.any { isPasswordHint(it) } && passwordId == null ->
                            passwordId = node.autofillId
                    }
                } else {
                    // Heuristic detection by input type and field hints
                    val inputType = node.inputType
                    when {
                        isPasswordInputType(inputType) && passwordId == null ->
                            passwordId = node.autofillId
                        isUsernameInputType(inputType, node) && usernameId == null ->
                            usernameId = node.autofillId
                    }
                }
            }
        }

        return AutofillFields(usernameId, passwordId, webDomain, packageName)
    }

    private fun traverseNode(
        node: AssistStructure.ViewNode?,
        action: (AssistStructure.ViewNode) -> Unit
    ) {
        node ?: return
        if (node.autofillType != View.AUTOFILL_TYPE_NONE) action(node)
        for (i in 0 until node.childCount) traverseNode(node.getChildAt(i), action)
    }

    private fun isPasswordHint(hint: String) = hint in setOf(
        View.AUTOFILL_HINT_PASSWORD, "password", "currentPassword", "newPassword"
    )

    private fun isUsernameHint(hint: String) = hint in setOf(
        View.AUTOFILL_HINT_USERNAME, View.AUTOFILL_HINT_EMAIL_ADDRESS,
        View.AUTOFILL_HINT_PHONE, "username", "email", "login"
    )

    private fun isPasswordInputType(inputType: Int): Boolean {
        val variation = inputType and InputType.TYPE_MASK_VARIATION
        return (inputType and InputType.TYPE_MASK_CLASS == InputType.TYPE_CLASS_TEXT) &&
                (variation == InputType.TYPE_TEXT_VARIATION_PASSWORD ||
                        variation == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD ||
                        variation == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD)
    }

    private fun isUsernameInputType(inputType: Int, node: AssistStructure.ViewNode): Boolean {
        val variation = inputType and InputType.TYPE_MASK_VARIATION
        val isEmailType = (inputType and InputType.TYPE_MASK_CLASS == InputType.TYPE_CLASS_TEXT) &&
                variation == InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
        val hint = node.hint?.toString()?.lowercase() ?: ""
        val isHeuristicUsername = hint.contains("user") || hint.contains("email") ||
                hint.contains("login") || hint.contains("mail")
        return isEmailType || isHeuristicUsername
    }

    private fun String.extractDomain(): String? {
        val url = this.lowercase()
        return when {
            url.contains("://") -> url.substringAfter("://").substringBefore("/").substringBefore("?")
            url.contains(".") -> url.substringBefore("/").substringBefore("?")
            else -> null
        }
    }
}
