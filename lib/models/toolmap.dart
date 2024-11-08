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
  final AlertLevel alertLevel;

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
    return ToolMap(
      id: json['id'],
      tool: Tool.fromJson(json['tool']),
      coordinate: Coordinate.fromJson(json['coordinate']),
      dispenser: Dispenser.fromJson(json['dispenser']),
      currentQuantity: json['currentQuantity'],
      maxQuantity: json['maxQuantity'],
      alertLevel: json['alertLevel'],
    );
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