import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aotm_fe_2/admin/authenticated_client.dart';
import 'package:aotm_fe_2/config.dart';
import 'package:aotm_fe_2/models/tool.dart';
import 'package:aotm_fe_2/models/toolmap.dart';
import 'package:aotm_fe_2/start/auth_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Tools extends StatefulWidget {
  @override
  ToolsState createState() => ToolsState();
}

class ToolsState extends State<Tools> {
  List<Tool> allTools = [];
  List<Tool> filteredTools = [];
  List<String> toolCategories = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    refreshTools();
    _loadToolCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshTools() async {
    List<Tool> fetchedTools = await _getTools();
    if (mounted) {
      setState(() {
        allTools = fetchedTools;
        _filterTools(_searchController.text);
      });
    }
  }

  Future<List<Tool>> _getTools() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/tools');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Tool.fromJson(json)).toList();
    } else {
      print('Failed to get tools with status code: ${response.statusCode}');
      return [];
    }
  }

  Future<List<String>> _loadToolCategories() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/tools/categories');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        toolCategories = List<String>.from(jsonResponse);
      });
      return toolCategories;
    } else {
      print(
          'Failed to get categories with status code: ${response.statusCode}');
      return [];
    }
  }

  void _filterTools(String searchTerm) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          if (searchTerm.isEmpty) {
            filteredTools = allTools;
          } else {
            filteredTools = allTools.where((tool) {
              return tool.toolName
                      .toLowerCase()
                      .contains(searchTerm.toLowerCase()) ||
                  tool.toolCategory
                      .toLowerCase()
                      .contains(searchTerm.toLowerCase()) ||
                  tool.toolId.toString().contains(searchTerm);
            }).toList();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Row(
          children: [
            Text('Tools',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ElevatedButton(
              onPressed: () => _addTool(context),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
              child: Icon(Icons.add),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tools...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _filterTools,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredTools.length,
        itemBuilder: (context, index) {
          return ToolCard(
            tool: filteredTools[index],
            onRefresh: refreshTools,
          );
        },
      ),
    );
  }

  Future<Tool?> _createTool(
      String name, String category, int size, String returnability) async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/tools');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'toolName': name,
        'toolCategory': category,
        'toolSize': size,
        'returnability': returnability,
      }),
    );

    if (response.statusCode == 201) {
      return Tool.fromJson(json.decode(response.body));
    } else {
      print('Failed to create tool with status code: ${response.statusCode}');
      return null;
    }
  }

  Future<void> _uploadToolImage(int toolId, File imageFile) async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/tools/$toolId/image');

    try {
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      var streamedResponse = await client.send(request);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        print('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void _addTool(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        final categoryController = TextEditingController();
        final sizeController = TextEditingController();
        String returnability = 'RETURNABLE';
        File? selectedImage;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                padding: EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add New Tool',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: selectedImage != null
                                  ? Image.file(selectedImage!,
                                      fit: BoxFit.cover)
                                  : Icon(Icons.build, size: 50),
                            ),
                            Positioned(
                              bottom: -10,
                              right: -10,
                              child: PopupMenuButton<String>(
                                icon: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                onSelected: (String choice) async {
                                  if (choice == 'camera') {
                                    final XFile? photo = await ImagePicker()
                                        .pickImage(source: ImageSource.camera);
                                    if (photo != null) {
                                      setState(() {
                                        selectedImage = File(photo.path);
                                      });
                                    }
                                  } else {
                                    final XFile? image = await ImagePicker()
                                        .pickImage(source: ImageSource.gallery);
                                    if (image != null) {
                                      setState(() {
                                        selectedImage = File(image.path);
                                      });
                                    }
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem(
                                    value: 'camera',
                                    child: Row(
                                      children: [
                                        Icon(Icons.camera_alt),
                                        SizedBox(width: 8),
                                        Text('Take Photo'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'gallery',
                                    child: Row(
                                      children: [
                                        Icon(Icons.photo_library),
                                        SizedBox(width: 8),
                                        Text('Choose from Gallery'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Tool Name',
                          prefixIcon: Icon(Icons.build),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      SizedBox(height: 16),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return toolCategories.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          categoryController.text = selection;
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Tool Category',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              helperText:
                                  'Select existing or type new category',
                            ),
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                          );
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: sizeController,
                        decoration: InputDecoration(
                          labelText: 'Tool Size (mm)',
                          prefixIcon: Icon(Icons.straighten),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (int.tryParse(value!) == null) {
                            return 'Must be a number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Text('Returnability'),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Returnable'),
                              value: 'RETURNABLE',
                              groupValue: returnability,
                              onChanged: (value) {
                                setState(() {
                                  returnability = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Non-Returnable'),
                              value: 'NONRETURNABLE',
                              groupValue: returnability,
                              onChanged: (value) {
                                setState(() {
                                  returnability = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cancel'),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final tool = await _createTool(
                                  nameController.text,
                                  categoryController.text,
                                  int.parse(sizeController.text),
                                  returnability,
                                );

                                if (tool != null && selectedImage != null) {
                                  await _uploadToolImage(
                                      tool.toolId, selectedImage!);
                                }

                                Navigator.pop(context);
                                refreshTools();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Create Tool'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ToolCard extends StatefulWidget {
  final Tool tool;
  final VoidCallback onRefresh;

  const ToolCard({
    Key? key,
    required this.tool,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _ToolCardState createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  List<ToolMap> toolMaps = [];
  bool isLoading = true;
  ImageProvider? toolImage;

  @override
  void initState() {
    super.initState();
    _loadToolData();
  }

  Future<void> _loadToolData() async {
    try {
      // Load the data sequentially instead of using Future.wait
      await _loadToolMaps();
      await _loadToolImage();
    } catch (e) {
      print('Error in _loadToolData: $e');
    }
  }

  Future<void> _loadToolMaps() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/toolmaps/tools/${widget.tool.toolId}');

    try {
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        if (mounted) {
          final List<ToolMap> parsedMaps = [];

          for (var item in jsonResponse) {
            try {
              final toolMap = ToolMap.fromJson(item as Map<String, dynamic>);
              parsedMaps.add(toolMap);
            } catch (e) {
              print('Error parsing individual tool map: $e');
              print('Problematic JSON: $item');
            }
          }

          setState(() {
            toolMaps = parsedMaps;
            isLoading = false;
          });
        }
      } else {
        print('Failed to fetch tool maps: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Exception in _loadToolMaps: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadToolImage() async {
    if (!mounted) return;

    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/tools/${widget.tool.toolId}/image');

    try {
      final response = await client.get(uri);
      if (response.statusCode == 200 && mounted) {
        final List<dynamic> base64Images = json.decode(response.body);
        if (base64Images.isNotEmpty) {
          final bytes = base64Decode(base64Images[0]);
          setState(() {
            toolImage = MemoryImage(bytes);
          });
        }
      }
    } catch (e) {
      print('Error loading tool image: $e');
    }
  }

  void _showToolDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tool Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: toolImage != null
                        ? Image(image: toolImage!, fit: BoxFit.cover)
                        : Icon(Icons.build, size: 80, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20),
                _detailRow('Tool ID', widget.tool.toolId.toString()),
                _detailRow('Name', widget.tool.toolName),
                _detailRow('Category', widget.tool.toolCategory),
                _detailRow('Size', '${widget.tool.toolSize} mm'),
                _detailRow('Returnability', widget.tool.returnability),
                Divider(),
                Text('Dispenser Locations:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                if (toolMaps.isEmpty)
                  Text('Not available in any dispenser',
                      style: TextStyle(fontStyle: FontStyle.italic))
                else
                  ...toolMaps
                      .map((toolMap) => Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${toolMap.dispenser.dispenserName}:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Quantity: ${toolMap.currentQuantity}/${toolMap.maxQuantity}'),
                                      Text(
                                          'Location: (${toolMap.coordinate.coordX}, ${toolMap.coordinate.coordZ})'),
                                      Text('Status: ${toolMap.alertLevel}',
                                          style: TextStyle(
                                            color: {
                                                  'HIGH': Colors.red,
                                                  'MEDIUM': Colors.orange,
                                                  'LOW': Colors.green,
                                                }[toolMap.alertLevel] ??
                                                Colors.black,
                                            fontWeight: FontWeight.w500,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ExpansionTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: toolImage != null
              ? Image(image: toolImage!, fit: BoxFit.cover)
              : Icon(Icons.build, size: 30, color: Colors.grey),
        ),
        title: Text(
          '${widget.tool.toolId} | ${widget.tool.toolName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.tool.toolCategory),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dispenser Locations:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (toolMaps.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Tool not currently mapped to any dispenser'),
                      ],
                    ),
                  )
                else
                  ...toolMaps
                      .map((toolMap) => _buildToolMapItem(toolMap))
                      .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolMapItem(ToolMap toolMap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(toolMap.dispenser.dispenserName),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: {
                        'HIGH': Colors.red[100],
                        'MEDIUM': Colors.orange[100],
                        'LOW': Colors.green[100],
                      }[toolMap.alertLevel] ??
                      Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${toolMap.currentQuantity}/${toolMap.maxQuantity}',
                  style: TextStyle(
                    color: {
                          'HIGH': Colors.red[900],
                          'MEDIUM': Colors.orange[900],
                          'LOW': Colors.green[900],
                        }[toolMap.alertLevel] ??
                        Colors.grey[900],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
            Padding(
              padding: EdgeInsets.only(left: 24, top: 4),
              child: Text(
                'Location: (${toolMap.coordinate.coordX}, ${toolMap.coordinate.coordZ})',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
