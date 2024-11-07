class Workshop {
  final int workshopId;
  final String workshopName;

  Workshop({required this.workshopId, required this.workshopName});

  const Workshop.nullWorkshop()
      : workshopId = -1,
        workshopName = 'null';

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      workshopId: json['workshopId'] ?? -1,
      workshopName: json['workshopName'] ?? 'null',
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