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
    try {
      return Coordinate(
        coordId: json['coordinateNo'], // Changed from coordId to coordinateNo
        coordZ: json['coordinateZ'],
        coordX: json['coordinateX'],
      );
    } catch (e) {
      print('Error parsing Coordinate:');
      print('JSON: $json');
      print('Error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'coordinateNo': coordId,  // Changed to match API response
      'coordinateZ': coordZ,
      'coordinateX': coordX,
    };
  }

  @override
  String toString() {
    return 'Coordinate{coordId: $coordId, coordZ: $coordZ, coordX: $coordX}';
  }
}