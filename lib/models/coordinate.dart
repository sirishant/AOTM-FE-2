class Coordinate {
  final int coordId;
  final int coordZ;
  final int coordX;

  Coordinate({
    required this.coordId,
    required this.coordZ,
    required this.coordX,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      coordId: json['coordId'],
      coordZ: json['coordZ'],
      coordX: json['coordX'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coordId': coordId,
      'coordZ': coordZ,
      'coordX': coordX,
    };
  }

  @override
  String toString() {
    return 'Coordinate{coordId: $coordId, coordZ: $coordZ, coordX: $coordX}';
  }
}