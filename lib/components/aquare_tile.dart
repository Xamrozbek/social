import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  Function()? onTap;

  SquareTile({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[200],
          ),
          child: Image.asset(imagePath, height: 34),
        ),
      ),
    );
  }
}
