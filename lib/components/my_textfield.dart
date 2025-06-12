import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final String title;
  final bool obscureText;
  final TextEditingController controller;


  const MyTextField({
    super.key,
    required this.title,
    required this.hintText,
    required this.obscureText,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [Text(title, style: TextStyle(color: Colors.grey))],
          ),
        ),
        SizedBox(height: 2),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: size.width * 0.8,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey),
              ),
              style: TextStyle(color: Colors.grey.shade900),
              obscureText: obscureText,
            ),
          ),
        ),
      ],
    );
  }
}
