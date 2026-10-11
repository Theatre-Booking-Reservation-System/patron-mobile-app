package com.example.haritha.patron_mobile_app

import android.Manifest
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.ContactsContract
import android.provider.Settings
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "patron/contacts")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(currentAccess())
                    "request" -> requestAccess(result)
                    "openSettings" -> {
                        val intent =
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.fromParts("package", packageName, null)
                            }
                        startActivity(intent)
                        result.success(null)
                    }
                    "load" -> result.success(loadContacts())
                    "shareImage" -> shareImage(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (requestCode != contactsPermissionRequest) {
            super.onRequestPermissionsResult(requestCode, permissions, grantResults)
            return
        }
        val result = pendingPermissionResult
        pendingPermissionResult = null
        when {
            grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED ->
                result?.success("granted")
            ActivityCompat.shouldShowRequestPermissionRationale(
                this,
                Manifest.permission.READ_CONTACTS,
            ) -> result?.success("denied")
            else -> result?.success("permanentlyDenied")
        }
    }

    private fun currentAccess(): String {
        val granted =
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) ==
                PackageManager.PERMISSION_GRANTED
        return if (granted) "granted" else "denied"
    }

    private fun requestAccess(result: MethodChannel.Result) {
        if (currentAccess() == "granted") {
            result.success("granted")
            return
        }
        if (pendingPermissionResult != null) {
            result.error("contacts", "Another permission request is in progress", null)
            return
        }
        pendingPermissionResult = result
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_CONTACTS),
            contactsPermissionRequest,
        )
    }

    private fun shareImage(call: MethodCall, result: MethodChannel.Result) {
        try {
            val channel = call.argument<String>("channel")
            val address = call.argument<String>("address").orEmpty()
            val subject = call.argument<String>("subject").orEmpty()
            val image = call.argument<ByteArray>("image")
            if (image == null || image.isEmpty() || address.isBlank()) {
                result.success(false)
                return
            }
            val file = File(cacheDir, "production-share.png")
            file.writeBytes(image)
            val uri =
                FileProvider.getUriForFile(
                    this,
                    "$packageName.fileprovider",
                    file,
                )
            if (channel == "email") {
                val email =
                    Intent(Intent.ACTION_SEND).apply {
                        type = "image/png"
                        putExtra(Intent.EXTRA_EMAIL, arrayOf(address))
                        putExtra(Intent.EXTRA_SUBJECT, subject)
                        putExtra(Intent.EXTRA_STREAM, uri)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        clipData = ClipData.newRawUri("production", uri)
                    }
                grantStreamAccess(email, uri)
                startActivity(Intent.createChooser(email, subject))
            } else {
                val message =
                    Intent(Intent.ACTION_SEND).apply {
                        type = "image/png"
                        putExtra(Intent.EXTRA_STREAM, uri)
                        putExtra("address", address)
                        putExtra("sms_body", "")
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        clipData = ClipData.newRawUri("production", uri)
                        Telephony.Sms.getDefaultSmsPackage(this@MainActivity)?.let { setPackage(it) }
                    }
                grantStreamAccess(message, uri)
                try {
                    startActivity(message)
                } catch (_: ActivityNotFoundException) {
                    message.setPackage(null)
                    grantStreamAccess(message, uri)
                    startActivity(message)
                }
            }
            result.success(true)
        } catch (_: Exception) {
            result.success(false)
        }
    }

    private fun grantStreamAccess(intent: Intent, uri: Uri) {
        val resolved =
            packageManager.queryIntentActivities(intent, PackageManager.MATCH_DEFAULT_ONLY)
        for (info in resolved) {
            grantUriPermission(
                info.activityInfo.packageName,
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        }
    }

    private fun loadContacts(): List<Map<String, Any>> {
        val people = mutableListOf<Map<String, Any>>()
        val cursor =
            contentResolver.query(
                ContactsContract.Contacts.CONTENT_URI,
                arrayOf(
                    ContactsContract.Contacts._ID,
                    ContactsContract.Contacts.DISPLAY_NAME,
                ),
                null,
                null,
                "${ContactsContract.Contacts.DISPLAY_NAME} COLLATE LOCALIZED ASC",
            ) ?: return people
        cursor.use {
            val idIndex = it.getColumnIndex(ContactsContract.Contacts._ID)
            val nameIndex = it.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME)
            while (it.moveToNext()) {
                val id = it.getString(idIndex) ?: continue
                people.add(
                    mapOf(
                        "id" to id,
                        "name" to (it.getString(nameIndex) ?: ""),
                        "phones" to phoneNumbers(id),
                        "emails" to emailAddresses(id),
                    ),
                )
            }
        }
        return people
    }

    private fun phoneNumbers(contactId: String): List<String> {
        val numbers = mutableListOf<String>()
        val cursor =
            contentResolver.query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                arrayOf(ContactsContract.CommonDataKinds.Phone.NUMBER),
                "${ContactsContract.CommonDataKinds.Phone.CONTACT_ID} = ?",
                arrayOf(contactId),
                null,
            ) ?: return numbers
        cursor.use {
            val index = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
            while (it.moveToNext()) {
                val number = it.getString(index)?.trim().orEmpty()
                if (number.isNotEmpty()) numbers.add(number)
            }
        }
        return numbers
    }

    private fun emailAddresses(contactId: String): List<String> {
        val addresses = mutableListOf<String>()
        val cursor =
            contentResolver.query(
                ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                arrayOf(ContactsContract.CommonDataKinds.Email.ADDRESS),
                "${ContactsContract.CommonDataKinds.Email.CONTACT_ID} = ?",
                arrayOf(contactId),
                null,
            ) ?: return addresses
        cursor.use {
            val index = it.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS)
            while (it.moveToNext()) {
                val address = it.getString(index)?.trim().orEmpty()
                if (address.isNotEmpty()) addresses.add(address)
            }
        }
        return addresses
    }

    private companion object {
        const val contactsPermissionRequest = 4101
    }
}
