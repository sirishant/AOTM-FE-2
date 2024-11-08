import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:aotm_fe_2/start/auth_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:aotm_fe_2/admin/authenticated_client.dart';
import 'package:aotm_fe_2/config.dart';
import 'package:aotm_fe_2/models/employee.dart';
import 'package:aotm_fe_2/models/job.dart';
import 'package:aotm_fe_2/models/workshop.dart';

class Employees extends StatefulWidget {
  @override
  EmployeesState createState() => EmployeesState();
}

class EmployeesState extends State<Employees> {
  List<Employee> allEmployees = [];
  List<Employee> filteredEmployees = [];
  List<Workshop> workshops = [];
  String? selectedWorkshop;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  final authStorage = AuthStorageService();

  @override
  void initState() {
    super.initState();
    refreshEmployees();
    _loadWorkshops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> refreshEmployees() async {
    List<Employee> fetchedEmployees = await _getEmployees();
    if (mounted) {
      setState(() {
        allEmployees = fetchedEmployees;
        _filterEmployees(_searchController.text);
      });
    }
  }

  Future<List<Employee>> _getEmployees() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/employees');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Employee.fromJson(json)).toList();
    } else {
      print('Failed to get employees with status code: ${response.statusCode}');
      return [];
    }
  }

  Future<void> _loadWorkshops() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/workshops');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      if (mounted) {
        setState(() {
          workshops =
              jsonResponse.map((json) => Workshop.fromJson(json)).toList();
        });
      }
    }
  }

  void _filterEmployees(String searchTerm) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          if (searchTerm.isEmpty && selectedWorkshop == null) {
            filteredEmployees = allEmployees;
          } else {
            filteredEmployees = allEmployees.where((employee) {
              bool matchesSearch = true;
              bool matchesWorkshop = true;

              if (searchTerm.isNotEmpty) {
                matchesSearch = employee.employeeName
                        .toLowerCase()
                        .contains(searchTerm.toLowerCase()) ||
                    employee.empId.toString().contains(searchTerm);
              }

              if (selectedWorkshop != null &&
                  selectedWorkshop != 'All Workshops') {
                matchesWorkshop =
                    employee.workshop.workshopName == selectedWorkshop;
              }

              return matchesSearch && matchesWorkshop;
            }).toList();
          }
        });
      }
    });
  }

  void _addEmployee() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final usernameController = TextEditingController();
        final firstNameController = TextEditingController();
        final lastNameController = TextEditingController();
        final passwordController = TextEditingController();
        final nfcTagController = TextEditingController();
        String? selectedRole = 'ROLE_USER';
        int? selectedWorkshopId;
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
                child: SingleChildScrollView(
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
                              'Add New Employee',
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
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: selectedImage != null
                                    ? FileImage(selectedImage!)
                                    : null,
                                child: selectedImage == null
                                    ? Icon(Icons.person, size: 50)
                                    : null,
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
                                          .pickImage(
                                              source: ImageSource.camera);
                                      if (photo != null) {
                                        setState(() {
                                          selectedImage = File(photo.path);
                                        });
                                      }
                                    } else {
                                      final XFile? image = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
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
                        Text(
                          'Employee Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                          onChanged: (value) {
                            final username =
                                '${value.toLowerCase()}_${lastNameController.text.toLowerCase()}'
                                    .replaceAll(' ', '_');
                            usernameController.text = username;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: lastNameController, // New controller
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                          onChanged: (value) {
                            // Auto-generate username from first and last name
                            final username =
                                '${firstNameController.text.toLowerCase()}_${value.toLowerCase()}'
                                    .replaceAll(' ', '_');
                            usernameController.text = username;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.account_circle_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Required' : null,
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'ROLE_USER',
                              child: Text('Operator'),
                            ),
                            DropdownMenuItem(
                              value: 'ROLE_ADMIN',
                              child: Text('Administrator'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: nfcTagController,
                          decoration: InputDecoration(
                            labelText: 'NFC Tag ID',
                            prefixIcon: Icon(Icons.nfc),
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
                        DropdownButtonFormField<int>(
                          value: selectedWorkshopId,
                          decoration: InputDecoration(
                            labelText: 'Workshop',
                            prefixIcon: Icon(Icons.business),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          hint: Text('Select Workshop'),
                          items: workshops.map((workshop) {
                            return DropdownMenuItem(
                              value: workshop.workshopId,
                              child: Text(workshop.workshopName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedWorkshopId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a workshop' : null,
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
                                  final employee = await _createEmployee(
                                    firstNameController.text,
                                    lastNameController.text,
                                    passwordController.text,
                                    selectedRole!,
                                    int.parse(nfcTagController.text),
                                    selectedWorkshopId!,
                                  );

                                  if (employee != null) {
                                    if (selectedImage != null) {
                                      await _uploadEmployeeImage(
                                          employee.empId, selectedImage!);
                                    }
                                    Navigator.pop(context);
                                    refreshEmployees();
                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Employee created successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Create Employee'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Employee?> _createEmployee(String firstName, String lastName,
      String password, String designation, int nfcTagId, int workshopId) async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/employees');

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstname': firstName,
          'lastname': lastName,
          'password': password,
          'designation': designation,
          'workshopId': workshopId,
          'nfcTagId': nfcTagId,
        }),
      );

      if (response.statusCode == 200) {
        return Employee.fromJson(json.decode(response.body));
      } else {
        print('Failed to create employee: ${response.statusCode}');
        // Show error toast or message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create employee. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    } catch (e) {
      print('Error creating employee: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating employee: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  Future<void> _uploadEmployeeImage(int empId, File imageFile) async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/employees/$empId/image');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Row(
          children: [
            Text('Employees',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ElevatedButton(
              onPressed: () {
                _addEmployee();
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search employees...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _filterEmployees,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedWorkshop,
              hint: Text('Select Workshop'),
              items: [
                DropdownMenuItem(value: null, child: Text('All Workshops')),
                ...workshops.map((workshop) {
                  return DropdownMenuItem(
                    value: workshop.workshopName,
                    child: Text(workshop.workshopName),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                setState(() {
                  selectedWorkshop = value;
                  _filterEmployees(_searchController.text);
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (context, index) {
                final employee = filteredEmployees[index];
                return EmployeeCard(
                  employee: employee,
                  onRefresh: refreshEmployees,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EmployeeCard extends StatefulWidget {
  final Employee employee;
  final VoidCallback onRefresh;

  const EmployeeCard({
    Key? key,
    required this.employee,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _EmployeeCardState createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  List<Job> jobs = [];
  bool isLoading = true;
  ImageProvider? employeeImage;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    await Future.wait([
      _loadEmployeeJobs(),
      _loadEmployeeImage(),
    ]);
  }

  Future<void> _loadEmployeeJobs() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/jobs/employees/${widget.employee.empId}');

    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            jobs = (json.decode(response.body) as List)
                .map((job) => Job.fromJson(job))
                .toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading employee jobs: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadEmployeeImage() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/employees/${widget.employee.empId}/image');

    try {
      final response = await client.get(uri);
      if (response.statusCode == 200) {
        if (mounted) {
          final List<dynamic> base64Images = json.decode(response.body);
          if (base64Images.isNotEmpty) {
            // Take the first image from the array
            final bytes = base64Decode(base64Images[0]);
            setState(() {
              employeeImage = MemoryImage(bytes);
            });
          }
        }
      }
    } catch (e) {
      print('Error loading employee image: $e');
    }
  }

  void _showEmployeeDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Employee Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: employeeImage ??
                        AssetImage('assets/images/default_avatar.png'),
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20),
                _detailRow('Employee ID', widget.employee.empId.toString()),
                _detailRow('Name', widget.employee.employeeName),
                _detailRow('Username', widget.employee.username),
                _detailRow('Designation', widget.employee.designation),
                _detailRow('NFC Tag ID', widget.employee.nfcTagId.toString()),
                _detailRow('Workshop', widget.employee.workshop.workshopName),
                _detailRow('Account Status',
                    widget.employee.enabled ? 'Active' : 'Inactive'),
                Divider(),
                Text('Assigned Jobs:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ...jobs
                    .map((job) => Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 8),
                          child: Text('• ${job.title}'),
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
        leading: CircleAvatar(
          radius: 25,
          backgroundImage:
              employeeImage ?? AssetImage('assets/images/default_avatar.png'),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(
          '${widget.employee.empId} | ${widget.employee.employeeName}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(widget.employee.workshop.workshopName),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned Jobs:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                if (isLoading)
                  Center(child: CircularProgressIndicator())
                else if (jobs.isEmpty)
                  Text('No jobs assigned')
                else
                  ...jobs
                      .map((job) => Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.work, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(job.title),
                                ),
                                Chip(
                                  label: Text(
                                    job.jobTools.isNotEmpty
                                        ? 'Active'
                                        : 'Pending',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: job.jobTools.isNotEmpty
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.info),
                      label: Text('View Details'),
                      onPressed: _showEmployeeDetails,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
