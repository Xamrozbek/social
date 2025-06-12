import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News', style: TextStyle(fontSize: 20))),
      body: Center(child: Text('No data yet!')),
    );
  }
}
