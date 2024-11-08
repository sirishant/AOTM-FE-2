import 'package:aotm_fe_2/models/tool.dart';
import 'package:aotm_fe_2/models/coordinate.dart';
import 'package:aotm_fe_2/models/dispenser.dart';

class ToolMap {
  final int id;
  final Tool tool;
  final Coordinate coordinate;
  final Dispenser dispenser;
  final int currentQuantity;
  final int maxQuantity;
  final String alertLevel;

  ToolMap({
    required this.id,
    required this.tool,
    required this.coordinate,
    required this.dispenser,
    required this.currentQuantity,
    required this.maxQuantity,
    required this.alertLevel,
  });

  factory ToolMap.fromJson(Map<String, dynamic> json) {
    // Add debug print to see the exact JSON structure
    print('Parsing ToolMap JSON: $json');
    
    try {
      return ToolMap(
        id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
        tool: Tool.fromJson(json['tool'] as Map<String, dynamic>),
        coordinate: Coordinate.fromJson(json['coordinate'] as Map<String, dynamic>),
        dispenser: Dispenser.fromJson(json['dispenser'] as Map<String, dynamic>),
        currentQuantity: json['currentQuantity'] is int ? json['currentQuantity'] : int.parse(json['currentQuantity'].toString()),
        maxQuantity: json['maxQuantity'] is int ? json['maxQuantity'] : int.parse(json['maxQuantity'].toString()),
        alertLevel: json['alertLevel']?.toString() ?? 'LOW',
      );
    } catch (e, stackTrace) {
      print('Error details in ToolMap.fromJson:');
      print('id type: ${json['id']?.runtimeType}');
      print('currentQuantity type: ${json['currentQuantity']?.runtimeType}');
      print('maxQuantity type: ${json['maxQuantity']?.runtimeType}');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tool': tool.toJson(),
      'coordinate': coordinate.toJson(),
      'dispenser': dispenser.toJson(),
      'currentQuantity': currentQuantity,
      'maxQuantity': maxQuantity,
      'alertLevel': alertLevel,
    };
  }

  @override
  String toString() {
    return 'ToolMap{id: $id, tool: $tool, coordinate: $coordinate, dispenser: $dispenser, currentQuantity: $currentQuantity, maxQuantity: $maxQuantity, alertLevel: $alertLevel}';
  }
}