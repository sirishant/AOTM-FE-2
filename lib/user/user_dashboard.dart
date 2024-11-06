import 'package:aotm_fe_2/main.dart';
import 'package:flutter/material.dart';
import '../start/auth_storage_service.dart';

class UserDashboard extends StatefulWidget {
  @override
  UserDashboardState createState() => UserDashboardState();
}

class UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to the User Dashboard'),
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