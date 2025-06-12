import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import androidx.core.app.NotificationCompat
import com.example.theclockapp.MainActivity

//package com.example.theclockapp
//
//import android.app.*
//import android.content.*
//import android.os.Build
//import androidx.core.app.NotificationCompat
////import com.example.theclockapp.R
//
//class AlarmReceiver : BroadcastReceiver() {
//    override fun onReceive(context: Context, intent: Intent) {
//        val title = "Alarm is Ringing!"
//        val body = "Tap to open the app or stop the alarm."
//
//        val notificationManager =
//            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//
//        val channelId = "alarm_channel"
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val channel = NotificationChannel(
//                channelId, "Alarms", NotificationManager.IMPORTANCE_HIGH
//            ).apply {
//                description = "Channel for alarm notifications"
//                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
//            }
//            notificationManager.createNotificationChannel(channel)
//        }
//
//        val intentToLaunch = Intent(context, MainActivity::class.java)
//        val pendingIntent = PendingIntent.getActivity(
//            context, 0, intentToLaunch,
//            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
//        )
//
//        val notification = NotificationCompat.Builder(context, channelId)
//            .setSmallIcon(R.mipmap.ic_launcher)
//            .setContentTitle(title)
//            .setContentText(body)
//            .setPriority(NotificationCompat.PRIORITY_HIGH)
//            .setFullScreenIntent(pendingIntent, true)
//            .setContentIntent(pendingIntent)
//            .setAutoCancel(true)
//            .setDefaults(Notification.DEFAULT_ALL)
//            .build()
//
//        notificationManager.notify(999, notification)
//    }
//}

//
//
//package com.example.theclockapp
//
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.embedding.engine.FlutterEngineCache
//import io.flutter.plugin.common.BasicMessageChannel
//import io.flutter.plugin.common.StringCodec
//
//class AlarmActionReceiver : BroadcastReceiver() {
//    override fun onReceive(context: Context, intent: Intent) {
//        if (intent.action == "CANCEL_ALARM") {
//            val engine = FlutterEngineCache.getInstance().get("main_engine")
//            if (engine != null) {
//                BasicMessageChannel<String>(engine.dartExecutor, "alarm_event_channel", StringCodec.INSTANCE)
//                    .send("{\"type\": \"alarm_cancelled\"}")
//            }
//        }
//    }
//}


class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title") ?: "Alarm"
        val message = intent.getStringExtra("message") ?: "Your alarm is ringing!"

        val channelId = "alarm_channel_id"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Alarm Notifications",
                NotificationManager.IMPORTANCE_HIGH
            )
            notificationManager.createNotificationChannel(channel)
        }

        val notificationIntent = Intent(context, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            context, 0, notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(message)
            .setAutoCancel(true)
            .setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM))
            .setContentIntent(pendingIntent)
            .build()

        notificationManager.notify(System.currentTimeMillis().toInt(), notification)
    }
}