package com.example.theclockapp

import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val RINGTONE_CHANNEL = "ringtone_picker"
    private val ALARM_CHANNEL = "alarm_notification"

    companion object {
        var backgroundFlutterEngine: FlutterEngine? = null
    }

    @RequiresApi(Build.VERSION_CODES.S)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register ringtone picker channel (UI)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RINGTONE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getSystemRingtones") {
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

        //forNotification
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "showNotification") {
                    Log.i(
                        "AlarmDebug",
                        "Registering mainactivity alarm_notification"
                    )

                    val title = call.argument<String>("title") ?: "Alarm"
                    val message = call.argument<String>("message") ?: "Your alarm is ringing!"

                    val intent = Intent(context, AlarmReceiver::class.java)
                    intent.putExtra("title", title)
                    intent.putExtra("message", message)
                    context.sendBroadcast(intent)

                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
