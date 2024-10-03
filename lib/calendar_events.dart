
import 'calendar_events_platform_interface.dart';

class CalendarEvents {
  Future<String?> getPlatformVersion() {
    return CalendarEventsPlatform.instance.getPlatformVersion();
  }
  
}
