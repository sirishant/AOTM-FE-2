import 'package:flutter/material.dart';
import './loginservice.dart';

import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginService _loginService = LoginService(baseUrl: 'https://100.100.187.101:8443');

  void _login() async {
    try {
      final response = await _loginService.login(_usernameController.text, _passwordController.text);
      print('Login successful: $response');
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
          fontSize: 16.0
        );
      } else {
        Fluttertoast.showToast(
          msg: "Internal server error: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.yellow,
          textColor: Colors.black,
          fontSize: 16.0
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

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
                          Text('Face Recognition', style: TextStyle(fontSize: 20)),
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
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Face Recognition', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(250, 0, 250, 0),
                      child: Placeholder(fallbackHeight: 200, fallbackWidth: 200),
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