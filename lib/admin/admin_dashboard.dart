import 'package:aotm_fe_2/main.dart';
import 'package:flutter/material.dart';
import '../start/auth_storage_service.dart';

class AdminDashboard extends StatefulWidget {
  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, Admin!'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the Admin Dashboard'),
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
