import 'package:calendar_events/event.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'calendar_events_method_channel.dart';

abstract class CalendarEventsPlatform extends PlatformInterface {
  /// Constructs a CalendarEventsPlatform.
  CalendarEventsPlatform() : super(token: _token);

  static final Object _token = Object();

  static CalendarEventsPlatform _instance = MethodChannelCalendarEvents();

  /// The default instance of [CalendarEventsPlatform] to use.
  ///
  /// Defaults to [MethodChannelCalendarEvents].
  static CalendarEventsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CalendarEventsPlatform] when
  /// they register themselves.
  static set instance(CalendarEventsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> addEvents({required List<Event> events}) async {
    throw UnimplementedError('No events method found');
  }
}
