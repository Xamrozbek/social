import 'package:flutter/material.dart';

class MyCountItem extends StatelessWidget {
  final String count;
  final String text;

  const MyCountItem({super.key, required this.count, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(text, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
