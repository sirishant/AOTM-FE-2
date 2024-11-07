class Workshop {
  final int workshopId;
  final String workshopName;

  Workshop({required this.workshopId, required this.workshopName});

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      workshopId: json['workshopId'],
      workshopName: json['workshopName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workshopId': workshopId,
      'workshopName': workshopName,
    };
  }

  @override
  String toString() {
    return 'Workshop{workshopId: $workshopId, workshopName: $workshopName}';
  }
}