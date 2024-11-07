import 'package:aotm_fe_2/config.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'login_service.dart';
import 'auth_storage_service.dart';

import '../admin/admin_dashboard.dart';
import '../user/user_dashboard.dart';

import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  Timer? _timer;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService =
      LoginService(baseUrl: baseUrl);

  void _login() async {
    final authStorage = AuthStorageService();

    try {
      final response = await _loginService.login(
          _usernameController.text, _passwordController.text);

      if (response['token'] != null) {
        // Store all the auth data
        await authStorage.saveToken(response['token']);
        await authStorage.saveExpiry(response['expiry']);
        await authStorage.saveRole(response['role']);
        await authStorage.saveEmpId(response['empId']);
        await authStorage.saveWorkshopId(response['workshopId']);

        // Navigate based on role
        _handleSuccessfulLogin(response['role']);
      } else {
        throw Exception('Login failed 500');
      }
    } catch (e) {
      print('Login failed: $e');
      if (e.toString().contains('401')) {
        Fluttertoast.showToast(
            msg: "Incorrect credentials. Please try again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Internal server error: $e",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.yellow,
            textColor: Colors.black,
            fontSize: 16.0);
      }
    }
  }

  void _handleSuccessfulLogin(String role) {
    // Remove all previous routes and navigate to the appropriate dashboard
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            role == "ROLE_ADMIN" ? AdminDashboard() : UserDashboard(),
      ),
      (route) => false, // This removes all previous routes from the stack
    );
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 60), () {
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Theme(
      data: ThemeData(
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Welcome!'),
        ),
        body: Center(
          child: isLandscape
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Face Recognition',
                              style: TextStyle(fontSize: 20)),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(100, 0, 100, 0),
                            child: Placeholder(fallbackHeight: 200),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 500,
                      child: VerticalDivider(),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Login', style: TextStyle(fontSize: 20)),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(150, 0, 150, 0),
                            child: TextField(
                              controller: _usernameController,
                              decoration:
                                  InputDecoration(labelText: 'Username'),
                            ),
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(150, 0, 150, 0),
                            child: TextField(
                              controller: _passwordController,
                              decoration:
                                  InputDecoration(labelText: 'Password'),
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _login,
                            child: Text('Sign In'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Face Recognition', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(250, 0, 250, 0),
                      child:
                          Placeholder(fallbackHeight: 200, fallbackWidth: 200),
                    ),
                    SizedBox(height: 120),
                    Divider(),
                    SizedBox(height: 120),
                    Text('Login', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(150, 0, 150, 0),
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(150, 0, 150, 0),
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Sign In'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
