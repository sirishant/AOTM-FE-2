class CustomNotification {
  final String type;
  final String title;
  final String description;
  final String workshopName;
  final Map<String, dynamic> data;

  CustomNotification({
    required this.type,
    required this.title,
    required this.description,
    required this.workshopName,
    required this.data,
  });

  factory CustomNotification.fromJson(Map<String, dynamic> json) {
    return CustomNotification(
      type: json['type'],
      title: json['title'],
      description: json['description'],
      workshopName: json['workshopName'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'workshopName': workshopName,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'Notification{type: $type, title: $title, description: $description, workshopName: $workshopName, data: $data}';
  }
}