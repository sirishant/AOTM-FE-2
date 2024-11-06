import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
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
      ),
    );
  }
}