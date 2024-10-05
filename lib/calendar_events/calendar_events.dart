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
}