import 'dart:convert';

import 'package:aotm_fe_2/models/employee.dart';
import 'package:aotm_fe_2/models/machine.dart';
import 'package:aotm_fe_2/models/tool.dart';
import 'package:aotm_fe_2/models/workshop.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:aotm_fe_2/admin/authenticated_client.dart';
import 'package:aotm_fe_2/config.dart';
import 'package:aotm_fe_2/models/job.dart';
import 'package:aotm_fe_2/start/auth_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class Jobs extends StatefulWidget {
  @override
  JobsState createState() => JobsState();
}

class JobsState extends State<Jobs> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  List<Job> allJobs = [];
  List<Job> filteredJobs = [];
  List<Workshop> workshops = [];
  List<Machine> machines = [];
  List<Tool> tools = [];

  @override
  void initState() {
    super.initState();
    refreshJobs();
    _loadWorkshops();
    _loadMachines();
    _loadTools();
  }

  void refreshJobs() async {
    List<Job> fetchedJobs = await _getJobs();
    if (mounted) {
      setState(() {
        allJobs = fetchedJobs;
      });
    }
  }

  Future<void> _loadWorkshops() async {
    List<Workshop> fetchedWorkshops = await _getWorkshops();
    if (mounted) {
      setState(() {
        workshops = fetchedWorkshops;
      });
    }
  }

  Future<void> _loadMachines() async {
    List<Machine> fetchedMachines = await _getMachines();
    setState(() {
      machines = fetchedMachines;
    });
  }

  Future<void> _loadTools() async {
    List<Tool> fetchedTools = await _getTools();
    if (mounted) {
      setState(() {
        tools = fetchedTools;
      });
    }
  }

  Future<List<Job>> _getJobs() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/jobs');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Job.fromJson(json)).toList();
    } else {
      print('Failed to get jobs with status code: ${response.statusCode}');
      return [];
    }
  }

  Future<List<Workshop>> _getWorkshops() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/workshops');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Workshop.fromJson(json)).toList();
    } else {
      print('Failed to get workshops with status code: ${response.statusCode}');
      return [];
    }
  }

  Future<List<Machine>> _getMachines() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/machines');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Machine.fromJson(json)).toList();
    } else {
      print('Failed to get machines with status code: ${response.statusCode}');
      return [];
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

  void _addJob() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          // needed fields: title, description, workshopId, machineId
          // employeeIds, toolmaps are not needed, will be added later in the form
          final titleController = TextEditingController();
          final descriptionController = TextEditingController();
          final workshopIdController = TextEditingController();
          final machineIdController = TextEditingController();

          return AlertDialog(
            title: Text('Add Job'),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5, // Increase width
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: null,
                    items: [
                      DropdownMenuItem<int>(
                        value: null,
                        child: Text(
                          'Select Workshop',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w400),
                        ),
                      ),
                      ...workshops.map((workshop) {
                        return DropdownMenuItem<int>(
                          value: workshop.workshopId,
                          child: Text(workshop.workshopName),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      workshopIdController.text = value.toString();
                    },
                    decoration: InputDecoration(
                      labelText: 'Workshop',
                    ),
                  ),
                  SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: workshopIdController,
                    builder: (context, TextEditingValue value, _) {
                      final filteredMachines = machines
                          .where((machine) =>
                              machine.workshop.workshopId ==
                              int.tryParse(value.text))
                          .toList();
                      return DropdownButtonFormField<int>(
                        value: filteredMachines.isNotEmpty
                            ? filteredMachines[0].machineNo
                            : null,
                        items: filteredMachines.map((machine) {
                          return DropdownMenuItem<int>(
                            value: machine.machineNo,
                            child: Text(machine.machineName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          machineIdController.text = value.toString();
                        },
                        decoration: InputDecoration(
                          labelText: 'Machine',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  addJobToDatabase(
                    titleController.text,
                    descriptionController.text,
                    int.parse(workshopIdController.text),
                    int.parse(machineIdController.text),
                  );
                  Navigator.of(context).pop();
                },
                child: Text('Add'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

  void addJobToDatabase(
      String title, String description, int workshopId, int machineId) async {
    print(
        'Attempting to add job with title: $title, description: $description, workshopId: $workshopId, machineId: $machineId');

    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/jobs');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'description': description,
        'workshopId': workshopId,
        'machineId': machineId
      }),
    );

    if (response.statusCode == 201) {
      print('Job added successfully');
      refreshJobs();
    } else {
      print('Failed to add job with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Row(
          children: [
            Text('Jobs',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ElevatedButton(
              onPressed: () {
                _addJob();
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
              child: Icon(Icons.add),
            ),
          ],
        ),
        actions: [
          // search bar with text and button icon
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // workshop dropdown
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: WorkshopDropdown(
                jobs: allJobs,
                onFiltered: (filteredJobs) {
                  setState(() {
                    this.filteredJobs = filteredJobs;
                  });
                },
              ),
            ),
            // list of jobs as ExpansionTile
            Expanded(
              child: ListView.builder(
                itemCount: filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = filteredJobs[index];
                  bool isExpanded = false;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        color: isExpanded
                            ? Colors.blue.withOpacity(0.02)
                            : Colors.transparent,
                        child: ExpansionTile(
                          title: Text(
                            'Job #${job.jobId} | ${job.title}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          onExpansionChanged: (expanded) {
                            setState(() {
                              isExpanded = expanded;
                            });
                          },
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ToolsDataTable(
                                        job: job,
                                        allJobs: allJobs,
                                        refreshJobs: refreshJobs,
                                        tools: tools,
                                        navigatorKey: navigatorKey),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ToolsDataTable extends StatelessWidget {
  final Job job;
  final Function refreshJobs;
  final List<Job> allJobs;
  final List<Tool> tools;
  final GlobalKey<NavigatorState> navigatorKey;

  ToolsDataTable({
    required this.job,
    required this.allJobs,
    required this.refreshJobs,
    required this.tools,
    required this.navigatorKey,
  });

  void addToolsToJobInDatabase(
      int jobId, List<int> toolIds, List<int> quantities) async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/jobs/$jobId/tools');

    final Map<int, int> toolQuantityMap = {};
    for (int i = 0; i < toolIds.length; i++) {
      toolQuantityMap[toolIds[i]] = quantities[i];
    }

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(toolQuantityMap
            .map((key, value) => MapEntry(key.toString(), value))),
      );

      if (response.statusCode == 201) {
        _showToast("Tools added successfully", Colors.green, Colors.white);
        refreshJobs();
      } else {
        _showToast("Failed to add tools", Colors.red, Colors.white);
      }
    } catch (e) {
      _showToast("Error: ${e.toString()}", Colors.red, Colors.white);
    }
  }

  void addToolsToJob(BuildContext context) {
    final controller = MultiSelectController<Tool>();
    final quantitiesController = TextEditingController();

    // Create items list from all available tools
    var items = tools.map((tool) {
      return DropdownItem(label: tool.toolName, value: tool);
    }).toList();

    // Pre-select existing tools and set their quantities
    List<String> initialQuantities = [];
    List<DropdownItem<Tool>> preSelectedItems = [];

    for (var jobTool in job.jobTools) {
      var matchingItem = items.firstWhere(
        (item) => item.value.toolId == jobTool.tool.toolId,
        orElse: () => DropdownItem(label: '', value: jobTool.tool),
      );
      preSelectedItems.add(matchingItem);
      initialQuantities.add(jobTool.quantity.toString());
    }

    // Set initial values
    controller.setItems(preSelectedItems);
    quantitiesController.text = initialQuantities.join(',');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Manage Tools for Job'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Job #${job.jobId} | ${job.title}'),
                    SizedBox(height: 16),
                    // Currently allocated tools section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Currently Allocated Tools:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          if (job.jobTools.isNotEmpty)
                            ...job.jobTools.map((jobTool) => Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Text(
                                    '${jobTool.tool.toolName} (Qty: ${jobTool.quantity})',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ))
                          else
                            Padding(
                              padding: EdgeInsets.only(left: 8, top: 4),
                              child: Text(
                                'No tools currently allocated',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    MultiDropdown<Tool>(
                      items: items,
                      controller: controller,
                      enabled: true,
                      searchEnabled: true,
                      chipDecoration: const ChipDecoration(
                        backgroundColor: Colors.blue,
                        wrap: true,
                        runSpacing: 2,
                        spacing: 10,
                      ),
                      fieldDecoration: FieldDecoration(
                        hintText: 'Select tools from the list',
                        hintStyle: const TextStyle(color: Colors.black54),
                        prefixIcon: const Icon(Icons.add_circle_outline),
                        showClearIcon: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black87),
                        ),
                      ),
                      dropdownDecoration: DropdownDecoration(
                        marginTop: 2,
                        maxHeight: 500,
                      ),
                      dropdownItemDecoration: DropdownItemDecoration(
                        selectedIcon:
                            const Icon(Icons.check_box, color: Colors.green),
                        disabledIcon:
                            Icon(Icons.lock, color: Colors.grey.shade300),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select at least one tool';
                        }
                        return null;
                      },
                      onSelectionChange: (selectedItems) {
                        setState(() {
                          List<String> newQuantities = [];
                          for (var item in selectedItems) {
                            var existingTool = job.jobTools.firstWhere(
                              (jobTool) => jobTool.tool.toolId == item.toolId,
                              orElse: () => JobTool(
                                  tool: item, quantity: 1, takenQuantity: 0),
                            );
                            newQuantities.add(existingTool.quantity.toString());
                          }
                          quantitiesController.text = newQuantities.join(',');
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...controller.selectedItems.map((item) {
                              int index =
                                  controller.selectedItems.indexOf(item);
                              String initialQuantity = '';
                              var existingTool = job.jobTools.firstWhere(
                                (jobTool) =>
                                    jobTool.tool.toolId == item.value.toolId,
                                orElse: () => JobTool(
                                    tool: item.value,
                                    quantity: 1,
                                    takenQuantity: 0),
                              );
                              initialQuantity =
                                  existingTool.quantity.toString();

                              return TextField(
                                decoration: InputDecoration(
                                  labelText: 'Quantity for ${item.label}',
                                ),
                                controller: TextEditingController(
                                    text: initialQuantity),
                                onChanged: (value) {
                                  List<String> quantities =
                                      quantitiesController.text.split(',');
                                  quantities[index] = value;
                                  quantitiesController.text =
                                      quantities.join(',');
                                },
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    final selectedTools = controller.selectedItems
                        .map((item) => item.value)
                        .toList();
                    final toolIds =
                        selectedTools.map((tool) => tool.toolId).toList();
                    final quantities = quantitiesController.text
                        .split(',')
                        .map((quantity) => int.parse(quantity))
                        .toList();

                    addToolsToJobInDatabase(job.jobId, toolIds, quantities);
                    Navigator.of(context).pop();
                  },
                  child: Text('Save Changes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showToast(String message, Color backgroundColor, Color textColor) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: textColor),
          SizedBox(width: 12.0),
          Text(message, style: TextStyle(color: textColor)),
        ],
      ),
    );

    FToast fToast = FToast();

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return job.jobTools.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No tools allocated for this job.',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    addToolsToJob(context);
                  },
                ),
              ],
            ),
          )
        : PaginatedDataTable(
            columnSpacing: MediaQuery.of(context).size.width * 0.1,
            header: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Job #${job.jobId}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Assigned to: ',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          {
                            for (Employee emp in job.employees)
                              '#${emp.empId} | ${_toCamelCase(emp.employeeName)}'
                          }.join(', '),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            columns: [
              DataColumn(
                  label: Expanded(
                      child: Text('Tool #', textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text('Tool Name', textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text('Withdrawn Quantity',
                          textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text('Quantity Assigned',
                          textAlign: TextAlign.center))),
              DataColumn(
                  label: Expanded(
                      child: Text('Modify', textAlign: TextAlign.center))),
            ],
            source: ToolsDataSource(
                job.jobTools, refreshJobs, job.jobId, navigatorKey, context),
            rowsPerPage: job.jobTools.length < 5 ? job.jobTools.length : 5,
            actions: [
              // edit button
              IconButton(
                icon: Icon(Icons.settings),
                color: Colors.black,
                onPressed: () {
                  addToolsToJob(context);
                },
              ),
            ],
          );
  }

  String _toCamelCase(String text) {
    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class ToolsDataSource extends DataTableSource {
  final List<JobTool> jobTools;
  final Function refreshJobs;
  final int jobId;
  final GlobalKey<NavigatorState> navigatorKey;
  final BuildContext context;
  late FToast fToast;

  ToolsDataSource(this.jobTools, this.refreshJobs, this.jobId,
      this.navigatorKey, this.context) {
    fToast = FToast();
    fToast.init(context);
  }

  void _showToast(String message, Color backgroundColor, Color textColor) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info, color: textColor),
          SizedBox(width: 12.0),
          Text(message, style: TextStyle(color: textColor)),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }

  Future<void> updateToolQuantity(int toolId, int newQuantity) async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri =
        Uri.parse('$baseUrl/jobs/$jobId/tools/$toolId?quantity=$newQuantity');

    try {
      final response = await client.patch(uri);

      if (response.statusCode == 200) {
        _showToast(
            "Tool quantity updated successfully", Colors.green, Colors.white);
        refreshJobs();
      } else {
        _showToast("Failed to update tool quantity", Colors.red, Colors.white);
      }
    } catch (e) {
      _showToast("Error: ${e.toString()}", Colors.red, Colors.white);
    }

    if (navigatorKey.currentState?.mounted ?? false) {
      Navigator.pop(context);
    }
  }

  Future<void> deleteToolFromJob(int toolId) async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/jobs/$jobId/tools/$toolId');

    try {
      final response = await client.delete(uri);

      if (response.statusCode == 204) {
        _showToast("Tool removed successfully", Colors.green, Colors.white);
        refreshJobs();
      } else {
        _showToast("Failed to remove tool", Colors.red, Colors.white);
      }
    } catch (e) {
      _showToast("Error: ${e.toString()}", Colors.red, Colors.white);
    }
  }

  @override
  DataRow getRow(int index) {
    final jobTool = jobTools[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(jobTool.tool.toolId.toString())),
      DataCell(Text(jobTool.tool.toolName)),
      DataCell(Text(jobTool.takenQuantity.toString())),
      DataCell(Text(jobTool.quantity.toString())),
      DataCell(Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Show edit dialog
              final TextEditingController quantityController =
                  TextEditingController(text: jobTool.quantity.toString());

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Edit Tool Quantity'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tool: ${jobTool.tool.toolName}'),
                      SizedBox(height: 10),
                      TextField(
                        controller: quantityController,
                        decoration: InputDecoration(
                          labelText: 'New Quantity',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final newQuantity =
                            int.tryParse(quantityController.text);
                        if (newQuantity != null && newQuantity > 0) {
                          updateToolQuantity(jobTool.tool.toolId, newQuantity);
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Confirm Removal'),
                  content: Text(
                      'Are you sure you want to remove ${jobTool.tool.toolName} from this job?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteToolFromJob(jobTool.tool.toolId);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text('Remove'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => jobTools.length;

  @override
  int get selectedRowCount => 0;
}

class WorkshopDropdown extends StatefulWidget {
  final List<Job> jobs;
  final Function(List<Job>) onFiltered;

  WorkshopDropdown({required this.jobs, required this.onFiltered});

  @override
  WorkshopDropdownState createState() => WorkshopDropdownState();
}

class WorkshopDropdownState extends State<WorkshopDropdown> {
  String? selectedWorkshop;

  @override
  Widget build(BuildContext context) {
    List<String> workshops =
        widget.jobs.map((job) => job.workshop.workshopName).toSet().toList();
    workshops.insert(0, 'All Workshops'); // Add "All Workshops" option

    return DropdownButton<String>(
      hint: Text(
        'Select Workshop',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      value: selectedWorkshop,
      onChanged: (String? newValue) {
        setState(() {
          selectedWorkshop = newValue;
        });
        if (newValue == 'All Workshops') {
          widget.onFiltered(widget.jobs);
        } else {
          widget.onFiltered(widget.jobs
              .where((job) => job.workshop.workshopName == newValue)
              .toList());
        }
      },
      items: workshops.map<DropdownMenuItem<String>>((String workshop) {
        return DropdownMenuItem<String>(
          value: workshop,
          child: Text(
            workshop,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        );
      }).toList(),
    );
  }
}
