
import 'package:calendar_events/calendar_events/calendar_events.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> events = [
      {
        'title': 'Meeting',
        'description': 'Description',
        'startDate': (DateTime.parse('2024-10-05 10:00:00')).millisecondsSinceEpoch.toString(),
        'endDate': (DateTime.parse('2024-10-05 11:00:00')).millisecondsSinceEpoch.toString(),
        'reminder': '10'
      },
      {
        'title': 'Lunch',
        'description': 'Description',
        'startDate': (DateTime.parse('2024-10-05 12:00:00')).millisecondsSinceEpoch.toString(),
        'endDate': (DateTime.parse('2024-10-05 13:00:00')).millisecondsSinceEpoch.toString(),
        'reminder': '10'
      }
    ];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Calendar Events')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: events.map((item) => Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Title: ${item['title']}"),
                            Text("Description: ${item['description']}"),
                            Text("Start Date: ${item['startDate']}"),
                            Text("End Date: ${item['endDate']}"),
                            Text("Reminder: ${item['reminder']} minute"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )).toList()
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            CalendarEvents calendarEvents = CalendarEvents();
            await calendarEvents.addEvents(events);
          },
          child: const Icon(Icons.event_available_rounded, size: 40,),
        ),
      ),
    );
  }
}
