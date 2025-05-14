package com.example.theclockapp

//import io.flutter.embedding.android.FlutterActivity
//
//class MainActivity: FlutterActivity()
import android.media.RingtoneManager
import android.os.Bundle
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "ringtone_picker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getSystemRingtones") {
                println("###inside methodcall")
                try {
                    val ringtoneList = mutableListOf<Map<String, String>>()

                    val manager = RingtoneManager(this)
                    manager.setType(RingtoneManager.TYPE_ALARM)

                    val cursor = manager.cursor
                    while (cursor.moveToNext()) {
                        val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                        val uri: Uri = manager.getRingtoneUri(cursor.position)
                        ringtoneList.add(mapOf("name" to title, "uri" to uri.toString()))
                    }

                    result.success(ringtoneList)
                } catch (e: Exception) {
                    result.error("ERROR", "Failed to get ringtones: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

