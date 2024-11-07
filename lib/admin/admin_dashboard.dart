import 'package:aotm_fe_2/admin/dispenser_tools.dart';
import 'package:aotm_fe_2/admin/jobs.dart';
import 'package:aotm_fe_2/main.dart';
import 'package:aotm_fe_2/models/dispenser.dart';
import 'package:aotm_fe_2/models/workshop.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../start/auth_storage_service.dart';
import 'authenticated_client.dart';
import '../models/notification.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config.dart';

class AdminDashboard extends StatefulWidget {
  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (_selectedIndex) {
      case 0:
        page = AdminDashHome();
        break;
      case 1:
        page = Jobs();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for index $_selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, Admin!',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.selected,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  selectedIcon: Icon(Icons.home_outlined),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.work),
                  selectedIcon: Icon(Icons.work_outline),
                  label: Text('Jobs'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  selectedIcon: Icon(Icons.person_outline),
                  label: Text('Operators'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.handyman),
                  selectedIcon: Icon(Icons.handyman_outlined),
                  label: Text('Tools'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: page,
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogout() async {
    final authStorage = AuthStorageService();
    await authStorage.clear();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => StartPage()),
      (route) => false,
    );
  }
}

class AdminDashHome extends StatefulWidget {
  AdminDashHome({super.key});

  @override
  AdminDashHomeState createState() => AdminDashHomeState();
}

class AdminDashHomeState extends State<AdminDashHome> {
  List<Workshop> workshops = [];
  List<Dispenser> dispensers = [];
  List<CustomNotification> notifications = [];
  List<Item> _notificationItems = [];

  @override
  void initState() {
    super.initState();
    _loadWorkshops();
    _loadDispensers();
    _loadNotifications();
  }

  Future<void> _loadWorkshops() async {
    List<Workshop> fetchedWorkshops = await _getWorkshops();
    setState(() {
      workshops = fetchedWorkshops;
    });
  }

  Future<void> _loadDispensers() async {
    List<Dispenser> fetchedDispensers = await _getDispensers();
    setState(() {
      dispensers = fetchedDispensers;
    });
  }

  Future<void> _loadNotifications() async {
    List<CustomNotification> fetchedNotifications = await _getNotifications();
    if (mounted) {
    setState(() {
      notifications = fetchedNotifications;
      _notificationItems = notifications
          .map((notification) => Item(
                type: notification.type,
                workshopName: notification.workshopName,
                headerValue: notification.title,
                expandedValue: '${notification.description}',
                data: {
                  if (notification.type == 'LOW_STOCK' ||
                      notification.type == 'MEDIUM_STOCK') ...{
                    'stockNotifications':
                        (notification.data['toolmaps'] as List<dynamic>)
                            .map((json) => StockNotification.fromJson(json))
                            .toList(),
                  } else ...{
                    'specialNotification':
                        SpecialNotification.fromJson(notification.data),
                  }
                },
              ))
          .toList();
    });
    }
  }

  List<Item> generateItems(List<CustomNotification> notifications) {
    return List<Item>.generate(notifications.length, (int index) {
      return Item(
        type: notifications[index].type,
        workshopName: notifications[index].workshopName,
        headerValue: notifications[index].title,
        expandedValue: notifications[index].description,
        data: {
          if (notifications[index].type == 'LOW_STOCK' ||
              notifications[index].type == 'MEDIUM_STOCK') ...{
            'stockNotifications':
                (notifications[index].data['toolmaps'] as List<dynamic>)
                    .map((json) => StockNotification.fromJson(json))
                    .toList(),
          } else ...{
            'specialNotification':
                SpecialNotification.fromJson(notifications[index].data),
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...workshops.map((workshop) {
                  final workshopDispensers = dispensers
                      .where((dispenser) =>
                          dispenser.workshop.workshopName ==
                          workshop.workshopName)
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${workshop.workshopName}',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      Row(
                        children: [
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: workshopDispensers.map((dispenser) {
                              Color color;
                              switch (dispenser.alertLevel) {
                                case 'HIGH':
                                  color = Colors.red;
                                  break;
                                case 'MEDIUM':
                                  color = Colors.orange;
                                  break;
                                case 'LOW':
                                  color = Colors.white70;
                                  break;
                                default:
                                  color = Colors.grey;
                              }
                              return SizedBox(
                                  width: 175, // Set a fixed width for the card
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DispenserTools()),
                                      );
                                    },
                                    child: SizedBox(
                                      width:
                                          175, // Set a fixed width for the card
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        color: color,
                                        child: Padding(
                                          padding: const EdgeInsets.all(30.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.print_outlined,
                                                size:
                                                    50.0, // Increase the size of the icon
                                                color: Colors.black,
                                              ),
                                              SizedBox(height: 8.0),
                                              Text(
                                                dispenser.dispenserName,
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            }).toList(),
                          ),
                          SizedBox(width: 20),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              _addDispenser(workshop.workshopName);
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _addWorkshop();
                  },
                  child: Text('New Workshop'),
                ),
                SizedBox(height: 20),
                Center(
                    child: Text('Analytics',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500))),
                SizedBox(height: 20),
                Placeholder(),
              ],
            ),
          ),
          SizedBox(width: 20),
          Column(
            children: [
              Text('Notifications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),
              _buildNotificationsList(),
              SizedBox(height: 80),
              SvgPicture.asset(
                'assets/icons/octaknight_logo.svg',
                semanticsLabel: 'Octaknight Logo',
                width: 200,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary, BlendMode.srcIn),
              ),
              SizedBox(height: 20),
            ],
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return SizedBox(
        width: 300, // Adjust this value based on needs
        child: _notificationItems.isEmpty
            ? Center(child: Text('No notifications'))
            : ExpansionPanelList(
                elevation: 1,
                expandedHeaderPadding: EdgeInsets.all(0),
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _notificationItems[index].isExpanded =
                        !_notificationItems[index].isExpanded;
                  });
                },
                children: _notificationItems.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                    backgroundColor: {
                      'LOW_STOCK': Colors.red[100],
                      'MEDIUM_STOCK': Colors.orange[100],
                      'SPECIAL_HISTORY': Colors.grey[100],
                    }[item.type],
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(
                        title: Text(item.headerValue),
                        subtitle: Text(item.expandedValue),
                      );
                    },
                    body: ListTile(
                        title: Text(
                          item.type == 'SPECIAL_HISTORY'
                              ? 'Tool not physically returned.'
                              : 'Refill immediately to avoid downtime.',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.data
                                .containsKey('stockNotifications')) ...[
                              for (StockNotification stockNotification
                                  in item.data['stockNotifications'])
                                Text(
                                  '${stockNotification.toolName} [${stockNotification.currentQuantity}/${stockNotification.maxQuantity}]',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                            ] else ...[
                              Text(
                                '''Quantity: ${item.data['specialNotification'].quantity}
Reason: ${item.data['specialNotification'].reason}
Time: ${item.data['specialNotification'].time}''',
                                style: TextStyle(fontSize: 12.0),
                              ),
                            ]
                          ],
                        )),
                    isExpanded: item.isExpanded,
                  );
                }).toList(),
              ));
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

  Future<List<Dispenser>> _getDispensers() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/dispensers');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Dispenser.fromJson(json)).toList();
    } else {
      print(
          'Failed to get dispensers with status code: ${response.statusCode}');
      return [];
    }
  }

  Future<List<CustomNotification>> _getNotifications() async {
    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/notifications/');
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((json) => CustomNotification.fromJson(json))
          .toList();
    } else {
      print(
          'Failed to get notifications with status code: ${response.statusCode}');
      return [];
    }
  }

  void _addDispenser(String workshopName) {
    showDialog(
      context: context,
      builder: (context) {
        final dispenserNameController = TextEditingController();
        return AlertDialog(
          title: Text('Add Dispenser'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dispenserNameController,
                decoration: InputDecoration(
                  labelText: 'Dispenser Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addDispenserToWorkshop(
                    dispenserNameController.text, workshopName);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addDispenserToWorkshop(
      String dispenserName, String workshopName) async {
    // get workshopId from workshopName
    final workshop = workshops.firstWhere(
        (workshop) => workshop.workshopName == workshopName,
        orElse: () => Workshop(workshopName: 'null', workshopId: -1));

    print(
        'Attempting to add dispenser $dispenserName to workshop ${workshop.workshopId}');

    if (workshop.workshopId == -1) {
      throw Exception('Workshop not found');
    }

    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/dispensers');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'dispenserName': dispenserName,
        'workshopId': workshop.workshopId,
      }),
    );

    if (response.statusCode == 200) {
      print('Dispenser added successfully');
      _loadDispensers();
    } else {
      print('Failed to add dispenser with status code: ${response.statusCode}');
    }
  }

  void _addWorkshop() {
    showDialog(
      context: context,
      builder: (context) {
        final workshopNameController = TextEditingController();
        return AlertDialog(
          title: Text('Add Workshop'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: workshopNameController,
                decoration: InputDecoration(
                  labelText: 'Workshop Name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addWorkshopToDatabase(workshopNameController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addWorkshopToDatabase(String workshopName) async {
    print('Attempting to add workshop $workshopName');

    final client = AuthenticatedClient(http.Client(), AuthStorageService());
    final uri = Uri.parse('$baseUrl/workshops');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': workshopName,
      }),
    );

    if (response.statusCode == 200) {
      print('Workshop added successfully');
      _loadWorkshops();
    } else {
      print('Failed to add workshop with status code: ${response.statusCode}');
    }
  }
}

class Item {
  String type;
  String workshopName;
  String headerValue;
  String expandedValue;
  bool isExpanded;
  Map<String, dynamic> data;

  Item(
      {required this.type,
      required this.workshopName,
      required this.headerValue,
      required this.expandedValue,
      required this.data,
      this.isExpanded = false});

  @override
  String toString() {
    return 'Item{type: $type workshopName: $workshopName, headerValue: $headerValue, expandedValue: $expandedValue, isExpanded: $isExpanded, data: $data}';
  }
}

class StockNotification {
  final int maxQuantity;
  final int currentQuantity;
  final String toolName;

  StockNotification({
    required this.maxQuantity,
    required this.currentQuantity,
    required this.toolName,
  });

  factory StockNotification.fromJson(Map<String, dynamic> json) {
    return StockNotification(
      maxQuantity: json['maxQuantity'],
      currentQuantity: json['currentQuantity'],
      toolName: json['toolName'],
    );
  }

  @override
  String toString() {
    return 'StockNotification{maxQuantity: $maxQuantity, currentQuantity: $currentQuantity, toolName: $toolName}';
  }
}

class SpecialNotification {
  final String employeeName;
  final int quantity;
  final String dispenserName;
  final String reason;
  final String toolName;
  final String time;

  SpecialNotification({
    required this.employeeName,
    required this.quantity,
    required this.dispenserName,
    required this.reason,
    required this.toolName,
    required this.time,
  });

  factory SpecialNotification.fromJson(Map<String, dynamic> json) {
    return SpecialNotification(
      employeeName: json['employeeName'],
      quantity: json['quantity'],
      dispenserName: json['dispenserName'],
      reason: json['reason'],
      toolName: json['toolName'],
      time: json['time'],
    );
  }

  @override
  String toString() {
    return 'SpecialNotification{employeeName: $employeeName, quantity: $quantity, dispenserName: $dispenserName, reason: $reason, toolName: $toolName, time: $time}';
  }
}
