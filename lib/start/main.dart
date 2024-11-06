import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './login.dart'; // Import the second page

void main() {
  runApp(AotmApp());
}

class AotmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AOTM',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  double _arrowOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _arrowOpacity = _arrowOpacity == 1.0 ? 0.0 : 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Octaknight Labs Pvt. Ltd.'),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            print('Swipe up detected');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        },
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/icons/octaknight_logo.svg',
                      semanticsLabel: 'Octaknight Logo',
                      width: 400,
                      color: Colors.black,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Welcome to AOTM!',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    AnimatedOpacity(
                      opacity: _arrowOpacity,
                      duration: Duration(seconds: 1),
                      child: AnimatedPadding(
                        duration: Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.only(bottom: _arrowOpacity == 1.0 ? 0 : 20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              size: 24.0,
                            ),
                            Text(
                              'Swipe up to continue',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}