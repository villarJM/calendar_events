import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalendarEvents {

  static const platform = MethodChannel('calendar_events');

  Future<void> addEvents(List<Map<String, dynamic>> events) async {
    try {
      await platform.invokeMethod('addEvents', {'events': events});
    } on PlatformException catch (e) {
      debugPrint("Failed to add events: '${e.message}'.");
    }
  }

  Future<void> fetchCalendars() async {

    try {
      final List<dynamic> calendars = await platform.invokeMethod('listCalendar');
      
      for (var calendar in calendars) {
        print('ID: ${calendar["id"]}, Display Name: ${calendar["displayName"]}, Account Name: ${calendar["accountName"]}, Is Primary: ${calendar["isPrimary"]}');
      }
    } on PlatformException catch (e) {
      print("Error al obtener calendarios: '${e.message}'.");
    }
}

}