import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome!'),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Face Recognition', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(200, 0, 200, 0),
                    child: Placeholder(fallbackHeight: 200, fallbackWidth: 200),
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
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(150, 0, 150, 0),
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Sign In'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}