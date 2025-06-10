package com.example.theclockapp

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val RINGTONE_CHANNEL = "ringtone_picker"
    private val ALARM_CHANNEL = "alarm_notification" // adjust if needed

    @RequiresApi(Build.VERSION_CODES.S)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Ringtone picker channel
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

//        // Native alarm scheduler channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "showNotification") {
                    val title = call.argument<String>("title") ?: "Alarm"
                    val body = call.argument<String>("body") ?: "It's time!"
                    showNativeNotification(applicationContext, title, body)
                    result.success(null)
                }
            }
    }

    companion object fun showNativeNotification(
        context: Context, title: String, body: String){
        val channelId = "alarm_channel_id"

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Alarm Notifications",
                NotificationManager.IMPORTANCE_HIGH
            )
            notificationManager.createNotificationChannel(channel)
        }
        val intent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(body)
            .setAutoCancel(true)
            .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION))
            .setContentIntent(pendingIntent)
            .build()

        notificationManager.notify(System.currentTimeMillis().toInt(), notification)

    }


}
