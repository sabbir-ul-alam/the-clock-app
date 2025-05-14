//package com.example.theclockapp
//
//import android.content.Context
//import android.media.RingtoneManager
//import android.net.Uri
//import io.flutter.embedding.engine.plugins.FlutterPlugin
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//
//class RingtonePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
//
//    private lateinit var channel: MethodChannel
//    private lateinit var context: Context
//
//    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        context = binding.applicationContext
//        channel = MethodChannel(binding.binaryMessenger, "ringtone_picker")
//        channel.setMethodCallHandler(this)
//    }
//
//    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//        channel.setMethodCallHandler(null)
//    }
//
//    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
//        when (call.method) {
//            "getSystemRingtones" -> {
//                println("##### inside methodcall in kotlin#####")
//                val ringtoneList = mutableListOf<Map<String, String>>()
//                val manager = RingtoneManager(context)
//                manager.setType(RingtoneManager.TYPE_ALARM)
//
//                val cursor = manager.cursor
//                while (cursor.moveToNext()) {
//                    val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
//                    val uri: Uri = manager.getRingtoneUri(cursor.position)
//                    ringtoneList.add(mapOf("name" to title, "uri" to uri.toString()))
//                }
//
//                result.success(ringtoneList)
//            }
//            else -> result.notImplemented()
//        }
//    }
//}
