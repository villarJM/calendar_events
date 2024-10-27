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
import java.util.Calendar

/** CalendarEventsPlugin */
class CalendarEventsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    private var pendingResult: Result? = null
    private var eventsToAdd: List<Map<String, String>>? = null

    companion object {
        private const val PERMISSION_REQUEST_CODE = 1001
    }


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "calendar_events")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "addEvents") {
            val events = call.argument<List<Map<String, String>>>("events")
            checkAndRequestPermissions(events, result)
        } else if (call.method == "listCalendar") {
            listCalendars(result)
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
            
            // Solicitar permisos
            ActivityCompat.requestPermissions(activity!!, 
                arrayOf(Manifest.permission.WRITE_CALENDAR), 
                PERMISSION_REQUEST_CODE)
            
            // Guardar el resultado para manejarlo más tarde
            pendingResult = result
            return
        }

        // Si se concede el permiso, continúa añadiendo eventos
        insertEvents(events, result)
    }

     private fun checkAndRequestPermissions(events: List<Map<String, String>>?, result: Result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is not attached", null)
            return
        }

        // Verificar permisos
        if (ContextCompat.checkSelfPermission(activity!!, Manifest.permission.READ_CALENDAR) != PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(activity!!, Manifest.permission.WRITE_CALENDAR) != PackageManager.PERMISSION_GRANTED) {
            
            pendingResult = result
            ActivityCompat.requestPermissions(activity!!, 
                arrayOf(Manifest.permission.READ_CALENDAR, Manifest.permission.WRITE_CALENDAR), 
                PERMISSION_REQUEST_CODE)
        } else {
            addEventsToCalendar(events, result)
        }
    }
    // Maneja la respuesta de la solicitud de permisos
    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode == PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permiso concedido, intenta añadir eventos
                pendingResult?.let { result ->
                    // Puedes volver a llamar a tu método aquí o implementar otra lógica para agregar eventos
                    insertEvents(eventsToAdd, result)
                    pendingResult = null
                }
            } else {
                pendingResult?.error("PERMISSION_DENIED", "Permission denied", null)
                pendingResult = null
            }
        }
    }

    private fun insertEvents(events: List<Map<String, String>>?, result: Result) {
        val contentResolver: ContentResolver = activity!!.contentResolver

        val calendarID = getCalendarID(contentResolver);
        Log.d("CalendarEventsPlugin", "insert $calendarID")
        for (event in events ?: emptyList()) {
            val values = ContentValues().apply {
                put(CalendarContract.Events.TITLE, event["title"])
                put(CalendarContract.Events.DESCRIPTION, event["description"])
                put(CalendarContract.Events.DTSTART, event["startDate"]?.toLong())
                put(CalendarContract.Events.DTEND, event["endDate"]?.toLong())
                put(CalendarContract.Events.CALENDAR_ID, calendarID)
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
            } else {
                Log.d("CalendarEventsPlugin", "Error al crear el evento")
            }
        }

        result.success("Events added successfully")
    }

    private fun getCalendarID(contentResolver: ContentResolver): Long? {
        val projection = arrayOf(CalendarContract.Calendars._ID)
        val cursor = contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI,
            projection,
            null,
            null,
            null
        )

        cursor?.use {
            if (it.moveToFirst()) {
                return it.getLong(it.getColumnIndex(CalendarContract.Calendars._ID))
            }
        }

        // Si no se encontró ningún calendario o el cursor es nulo, devuelve null
        return null
    }

    private fun listCalendars(result: Result ) {
        val contentResolver: ContentResolver = activity!!.contentResolver
        val calendarInfo = mutableListOf<Map<String, String>>()
        val projection = arrayOf(
            CalendarContract.Calendars._ID,
            CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,
            CalendarContract.Calendars.ACCOUNT_NAME,
            CalendarContract.Calendars.IS_PRIMARY
        )

        val cursor = contentResolver.query(
            CalendarContract.Calendars.CONTENT_URI,
            projection,
            null,
            null,
            null
        )

        cursor?.use {
            while (it.moveToNext()) {
                val id = it.getString(it.getColumnIndex(CalendarContract.Calendars._ID))
                val displayName = it.getString(it.getColumnIndex(CalendarContract.Calendars.CALENDAR_DISPLAY_NAME))
                val accountName = it.getString(it.getColumnIndex(CalendarContract.Calendars.ACCOUNT_NAME))
                val isPrimary = it.getInt(it.getColumnIndex(CalendarContract.Calendars.IS_PRIMARY)) == 1

                val calendarDetails = mapOf(
                    "id" to id,
                    "displayName" to displayName,
                    "accountName" to accountName,
                    "isPrimary" to isPrimary.toString()
                )

                calendarInfo.add(calendarDetails)

                // Log de la información del calendario
                Log.d("CalendarEventsPlugin", "Calendar ID: $id, Display Name: $displayName, Account Name: $accountName, Is Primary: $isPrimary")
            }
        }

        // Devuelve la información de los calendarios a Flutter
        result.success(calendarInfo)
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
