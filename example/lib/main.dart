
import 'package:calendar_events/calendar_events/calendar_events.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Calendar Events')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              CalendarEvents calendarEvents = CalendarEvents();
              await calendarEvents.addEvents([
                {
                  'title': 'Meeting',
                  'description': 'Description',
                  'startDate': (DateTime.parse('2024-09-21 10:00:00')).millisecondsSinceEpoch.toString(),
                  'endDate': (DateTime.parse('2024-09-21 11:00:00')).millisecondsSinceEpoch.toString(),
                  'reminder': '10'
                },
                {
                  'title': 'Lunch',
                  'description': 'Description',
                  'startDate': (DateTime.parse('2024-09-21 12:00:00')).millisecondsSinceEpoch.toString(),
                  'endDate': (DateTime.parse('2024-09-21 13:00:00')).millisecondsSinceEpoch.toString(),
                  'reminder': '10'
                }
              ]);
            },
            child: const Text('Add Events'),
          ),
        ),
      ),
    );
  }
}
