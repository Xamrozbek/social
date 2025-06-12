import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

class MyCircle extends StatelessWidget {
  IconData icon;
  Function()? onTap;

  MyCircle({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(
            width: 1,
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
        child: Center(child: Icon(icon, color: Colors.blue, size: 15)),
      ),
    );
  }
}
