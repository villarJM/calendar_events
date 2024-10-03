package com.villardev.calendar_events

import android.Manifest
import android.content.ContentResolver
import android.content.ContentUris
import android.content.ContentValues
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.CalendarContract
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.app.Activity

/** CalendarEventsPlugin */
class CalendarEventsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "calendar_events")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "addEvents") {
            val events = call.argument<List<Map<String, String>>>("events")
            addEventsToCalendar(events, result)
        } else {
            result.notImplemented()
        }
    }

    private fun addEventsToCalendar(events: List<Map<String, String>>?, result: Result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is not attached", null)
            return
        }

        // Verificar permisos
        if (ContextCompat.checkSelfPermission(activity!!, Manifest.permission.WRITE_CALENDAR)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(activity!!, arrayOf(Manifest.permission.WRITE_CALENDAR), 0)
            result.error("PERMISSION_DENIED", "Permission denied", null)
            return
        }

        val contentResolver: ContentResolver = activity!!.contentResolver

        for (event in events ?: emptyList()) {
            val values = ContentValues().apply {
                put(CalendarContract.Events.TITLE, event["title"])
                put(CalendarContract.Events.DESCRIPTION, event["description"])
                put(CalendarContract.Events.DTSTART, event["startDate"]?.toLong())
                put(CalendarContract.Events.DTEND, event["endDate"]?.toLong())
                put(CalendarContract.Events.CALENDAR_ID, 1)
                put(CalendarContract.Events.EVENT_TIMEZONE, "UTC")
            }

            val uri: Uri? = contentResolver.insert(CalendarContract.Events.CONTENT_URI, values)
            if (uri != null) {
              val eventId = ContentUris.parseId(uri)
              val reminderMinutes = event["reminder"]?.toIntOrNull() ?: 10
              val reminderValues = ContentValues().apply {
                  put(CalendarContract.Reminders.EVENT_ID, eventId)
                  put(CalendarContract.Reminders.MINUTES, reminderMinutes)
                  put(CalendarContract.Reminders.METHOD, CalendarContract.Reminders.METHOD_ALERT)
              }

              val reminderUri: Uri? = contentResolver.insert(CalendarContract.Reminders.CONTENT_URI, reminderValues)
              Log.d("CalendarEventsPlugin", "Reminder added: $reminderUri")
            }
        }

        result.success("Events added successfully")
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    // Implementación de ActivityAware
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
