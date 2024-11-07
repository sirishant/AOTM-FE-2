import 'package:flutter/material.dart';

class Jobs extends StatefulWidget {
  @override
  JobsState createState() => JobsState();
}

class JobsState extends State<Jobs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Jobs'),
          ],
        ),
      ),
      body: Center(
        child: Text('Jobs'),
      ),
    );
  }
}