import 'package:flutter/material.dart';

class MyIconsSquare extends StatelessWidget {
  final String iconPath;
  final Color color;

  const MyIconsSquare({super.key, required this.iconPath, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: Image.asset(iconPath, color: color),
    );
  }
}
