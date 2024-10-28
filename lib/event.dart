class Event {
    final String title;
    final String description;
    final String startDate;
    final String endDate;
    final String reminder;
    final String organizerId;

    Event({
        required this.title,
        required this.description,
        required this.startDate,
        required this.endDate,
        required this.reminder,
        required this.organizerId
    });

    factory Event.fromJson(Map<String, dynamic> json) => Event(
        title: json["title"],
        description: json["description"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        reminder: json["reminder"],
        organizerId: json["organizer_id"]
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "startDate": startDate,
        "endDate": endDate,
        "reminder": reminder,
        "organizer_id": organizerId
    };
}
