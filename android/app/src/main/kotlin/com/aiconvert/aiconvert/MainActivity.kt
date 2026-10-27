package com.aioconvert.aioconvert

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.webkit.MimeTypeMap
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.IOException

class MainActivity : FlutterActivity() {
    companion object {
        private const val OUTPUT_FOLDER_CHANNEL =
            "com.aioconvert.aioconvert/output_folder"
        private const val OUTPUT_FOLDER_REQUEST = 4201
        private const val OUTPUT_FOLDER_PREFERENCES = "aioconvert_output_folder"
        private const val OUTPUT_FOLDER_URI = "tree_uri"
    }

    private var pendingFolderResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            OUTPUT_FOLDER_CHANNEL,
        ).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "getOutputFolder" -> result.success(
                        storedOutputFolder()?.let(::folderInfo),
                    )

                    "chooseOutputFolder" -> chooseOutputFolder(result)
                    "saveOutputFile" -> result.success(saveOutputFile(call))
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error(
                    "output_folder_failed",
                    error.message ?: "Could not access the selected output folder.",
                    null,
                )
            }
        }
    }

    @Deprecated("Deprecated in Android")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != OUTPUT_FOLDER_REQUEST) return

        val result = pendingFolderResult ?: return
        pendingFolderResult = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }

        try {
            val grantFlags = data.flags and
                (Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            contentResolver.takePersistableUriPermission(uri, grantFlags)
            getSharedPreferences(OUTPUT_FOLDER_PREFERENCES, MODE_PRIVATE)
                .edit()
                .putString(OUTPUT_FOLDER_URI, uri.toString())
                .apply()
            result.success(folderInfo(uri))
        } catch (error: Exception) {
            result.error(
                "output_folder_permission_failed",
                error.message ?: "Could not retain access to the selected folder.",
                null,
            )
        }
    }

    private fun chooseOutputFolder(result: MethodChannel.Result) {
        if (pendingFolderResult != null) {
            result.error("output_folder_busy", "A folder picker is already open.", null)
            return
        }

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION,
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val initialUri = storedOutputFolder()?.let { folderUri ->
                    DocumentsContract.buildDocumentUriUsingTree(
                        folderUri,
                        DocumentsContract.getTreeDocumentId(folderUri),
                    )
                }
            if (initialUri != null) {
                intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, initialUri)
            }
        }

        pendingFolderResult = result
        try {
            startActivityForResult(intent, OUTPUT_FOLDER_REQUEST)
        } catch (error: Exception) {
            pendingFolderResult = null
            result.error(
                "output_folder_picker_unavailable",
                error.message ?: "No folder picker is available on this device.",
                null,
            )
        }
    }

    private fun storedOutputFolder(): Uri? =
        getSharedPreferences(OUTPUT_FOLDER_PREFERENCES, MODE_PRIVATE)
            .getString(OUTPUT_FOLDER_URI, null)
            ?.let { Uri.parse(it) }

    private fun folderInfo(uri: Uri): Map<String, String> {
        val documentId = DocumentsContract.getTreeDocumentId(uri)
        val documentUri =
            DocumentsContract.buildDocumentUriUsingTree(uri, documentId)
        val name = contentResolver.query(
            documentUri,
            arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) cursor.getString(0) else null
        } ?: documentId.substringAfterLast(':')

        return mapOf("uri" to uri.toString(), "name" to name)
    }

    private fun saveOutputFile(call: MethodCall): String {
        val sourcePath = call.argument<String>("sourcePath")
            ?: throw IllegalArgumentException("The converted file path is missing.")
        val extension = call.argument<String>("extension")
            ?: throw IllegalArgumentException("The output file extension is missing.")
        val requestedName = call.argument<String>("displayName")
            ?: throw IllegalArgumentException("The output file name is missing.")
        val folderUri = storedOutputFolder()
            ?: throw IllegalStateException("Choose an output folder before converting.")
        val sourceFile = File(sourcePath)
        if (!sourceFile.isFile) {
            throw IOException("The converted output file was not created.")
        }

        val treeDocumentId = DocumentsContract.getTreeDocumentId(folderUri)
        val parentUri =
            DocumentsContract.buildDocumentUriUsingTree(folderUri, treeDocumentId)
        val childrenUri =
            DocumentsContract.buildChildDocumentsUriUsingTree(folderUri, treeDocumentId)
        val existingNames = mutableSetOf<String>()
        contentResolver.query(
            childrenUri,
            arrayOf(DocumentsContract.Document.COLUMN_DISPLAY_NAME),
            null,
            null,
            null,
        )?.use { cursor ->
            while (cursor.moveToNext()) {
                existingNames += cursor.getString(0)
            }
        }

        val safeName = requestedName
            .substringAfterLast('/')
            .substringAfterLast('\\')
        val nameWithoutExtension = safeName.removeSuffix(".$extension")
        var candidate = safeName
        var suffix = 1
        while (candidate in existingNames) {
            candidate = "${nameWithoutExtension}_$suffix.$extension"
            suffix++
        }

        val mimeType = MimeTypeMap.getSingleton()
            .getMimeTypeFromExtension(extension.lowercase())
            ?: "application/octet-stream"
        val outputUri = DocumentsContract.createDocument(
            contentResolver,
            parentUri,
            mimeType,
            candidate,
        ) ?: throw IOException("The selected folder could not create an output file.")

        try {
            val outputStream = contentResolver.openOutputStream(outputUri)
                ?: throw IOException("The selected folder could not open the output file.")
            FileInputStream(sourceFile).use { input ->
                outputStream.use { output -> input.copyTo(output) }
            }
        } catch (error: Exception) {
            try {
                DocumentsContract.deleteDocument(contentResolver, outputUri)
            } catch (cleanupError: Exception) {
                android.util.Log.w(
                    "AIOconvert",
                    "Could not remove incomplete output document.",
                    cleanupError,
                )
            }
            throw error
        }

        return candidate
    }
}
