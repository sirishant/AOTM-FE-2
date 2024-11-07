import 'package:flutter/material.dart';

class DispenserTools extends StatefulWidget {
  @override
  DispenserToolsState createState() => DispenserToolsState();
}

class DispenserToolsState extends State<DispenserTools> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dispenser Tools'),
      ),
      body: Center(
        child: Text('Dispenser Tools'),
      ),
    );
  }
}