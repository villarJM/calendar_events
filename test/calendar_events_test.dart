// import 'package:flutter_test/flutter_test.dart';
// import 'package:calendar_events/calendar_events.dart';
// import 'package:calendar_events/calendar_events_platform_interface.dart';
// import 'package:calendar_events/calendar_events_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockCalendarEventsPlatform
//     with MockPlatformInterfaceMixin
//     implements CalendarEventsPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final CalendarEventsPlatform initialPlatform = CalendarEventsPlatform.instance;

//   test('$MethodChannelCalendarEvents is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelCalendarEvents>());
//   });

//   test('getPlatformVersion', () async {
//     CalendarEvents calendarEventsPlugin = CalendarEvents();
//     MockCalendarEventsPlatform fakePlatform = MockCalendarEventsPlatform();
//     CalendarEventsPlatform.instance = fakePlatform;

//     expect(await calendarEventsPlugin.getPlatformVersion(), '42');
//   });
// }
