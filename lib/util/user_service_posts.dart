import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserServicePosts extends StatelessWidget {
  final IconData icon;
  final Color color1;
  final Color color2;
  final Color color3;
  final String text;

  const UserServicePosts({
    super.key,
    required this.icon,
    required this.color1,
    required this.color2,
    required this.text,
    required this.color3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color1, // Bottom color
            color2, // Bottom color
            color3
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Shadow position
          ),
        ],
      ),
      height: 120,
      width: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40,color: CupertinoColors.white,),
            SizedBox(height: 10),
            Text(
              text,
              style: TextStyle(fontSize: 16, color: CupertinoColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
