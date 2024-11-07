class Tool {
  final int toolId;
  final String toolCategory;
  final String toolName;
  final int toolSize;
  final String returnability;

  Tool({
    required this.toolId,
    required this.toolCategory,
    required this.toolName,
    required this.toolSize,
    required this.returnability,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      toolId: json['toolId'],
      toolCategory: json['toolCategory'],
      toolName: json['toolName'],
      toolSize: json['toolSize'],
      returnability: json['returnability'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toolId': toolId,
      'toolCategory': toolCategory,
      'toolName': toolName,
      'toolSize': toolSize,
      'returnability': returnability,
    };
  }

  @override
  String toString() {
    return 'Tool{toolId: $toolId, toolCategory: $toolCategory, toolName: $toolName, toolSize: $toolSize, returnability: $returnability}';
  }
}