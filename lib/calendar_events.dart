import 'package:calendar_events/event.dart';
import 'package:calendar_events/calendar_events_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalendarEvents {

  static const platform = MethodChannel('calendar_events');

  Future<void> addEvents({required List<Event> events}) async {
    return CalendarEventsPlatform.instance.addEvents(events: events);
  }

  Future<void> fetchCalendars() async {

    try {
      final List<dynamic> calendars = await platform.invokeMethod('listCalendar');
      
      for (var calendar in calendars) {
        debugPrint('ID: ${calendar["id"]}, Display Name: ${calendar["displayName"]}, Account Name: ${calendar["accountName"]}, Is Primary: ${calendar["isPrimary"]}');
      }
    } on PlatformException catch (e) {
      debugPrint("Error al obtener calendarios: '${e.message}'.");
    }
}

}