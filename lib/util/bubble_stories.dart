import 'package:flutter/material.dart';

class BubbleStories extends StatelessWidget {
  final String text;

  const BubbleStories({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(height: 10),
          Text(text),
        ],
      ),
    );
  }
}
