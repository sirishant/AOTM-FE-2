import 'dart:convert';

import 'package:aotm_fe_2/models/employee.dart';
import 'package:http/http.dart' as http;
import 'package:aotm_fe_2/admin/authenticated_client.dart';
import 'package:aotm_fe_2/config.dart';
import 'package:aotm_fe_2/models/job.dart';
import 'package:aotm_fe_2/start/auth_storage_service.dart';
import 'package:flutter/material.dart';

class Jobs extends StatefulWidget {
  @override
  JobsState createState() => JobsState();
}

class JobsState extends State<Jobs> {
  List<Job> allJobs = [];
  List<Job> filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() async {
    List<Job> fetchedJobs = await _getJobs();
    if (mounted) {
      setState(() {
        allJobs = fetchedJobs;
        filteredJobs = fetchedJobs;
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              TextField(
                controller: workshopIdController,
                decoration: InputDecoration(
                  labelText: 'Workshop ID',
                ),
              ),
              TextField(
                controller: machineIdController,
                decoration: InputDecoration(
                  labelText: 'Machine ID',
                ),
              ),
            ],
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
      }
      );
  }

  void addJobToDatabase(String title, String description, int workshopId, int machineId) async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/jobs');
    final response = await client.post(
      uri,
      body: json.encode({
        'title': title,
        'description': description,
        'workshopId': workshopId,
        'machineId': machineId
      }),
    );

    if (response.statusCode == 201) {
      print('Job added successfully');
      _loadJobs();
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
            Text('Jobs', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ElevatedButton(
              onPressed: () {
                
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
                        color: isExpanded ? Colors.blue.withOpacity(0.02) : Colors.transparent,
                        child: ExpansionTile(
                          title: Text(
                            'Job #${job.jobId} | ${job.title}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
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
                                    child: ToolsDataTable(job: job),
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

  ToolsDataTable({required this.job});

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
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
        DataColumn(label: Expanded(child: Text('Tool #', textAlign: TextAlign.center))),
        DataColumn(label: Expanded(child: Text('Tool Name', textAlign: TextAlign.center))),
        DataColumn(label: Expanded(child: Text('Withdrawn Quantity', textAlign: TextAlign.center))),
        DataColumn(label: Expanded(child: Text('Quantity Assigned', textAlign: TextAlign.center))),
        DataColumn(label: Expanded(child: Text('Modify', textAlign: TextAlign.center))),
      ],
      source: ToolsDataSource(job.jobTools),
      rowsPerPage: job.jobTools.length < 5 ? job.jobTools.length : 5,
      actions: [
        // edit button
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // Add your onPressed code here!
          },
        ),
      ],
    );
  }

  String _toCamelCase(String text) {
    return text.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}

class ToolsDataSource extends DataTableSource {
  final List<JobTool> jobTools;

  ToolsDataSource(this.jobTools);

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
              // Add your edit code here!
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Add your delete code here!
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
    List<String> workshops = widget.jobs.map((job) => job.workshop.workshopName).toSet().toList();
    workshops.insert(0, 'All Workshops'); // Add "All Workshops" option

    return DropdownButton<String>(
      hint: Text('Select Workshop', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
      value: selectedWorkshop,
      onChanged: (String? newValue) {
        setState(() {
          selectedWorkshop = newValue;
        });
        if (newValue == 'All Workshops') {
          widget.onFiltered(widget.jobs);
        } else {
          widget.onFiltered(widget.jobs.where((job) => job.workshop.workshopName == newValue).toList());
        }
      },
      items: workshops.map<DropdownMenuItem<String>>((String workshop) {
        return DropdownMenuItem<String>(
          value: workshop,
          child: Text(workshop, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
        );
      }).toList(),
    );
  }
}