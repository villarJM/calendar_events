import 'package:calendar_events/event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'calendar_events_platform_interface.dart';

/// An implementation of [CalendarEventsPlatform] that uses method channels.
class MethodChannelCalendarEvents extends CalendarEventsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('calendar_events');

  @override
  Future<void> addEvents({ required List<Event> events}) async {
    List<Map<String, dynamic>> eventsListMap = events.map((event) => event.toJson()).toList();
    await methodChannel.invokeMethod('addEvents', {'events': eventsListMap});
  }
}
