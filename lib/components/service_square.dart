import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/themes/theme_provider.dart';

class ServiceSquare extends StatelessWidget {
  IconData icon;
  String text;

  ServiceSquare({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Center(
      child: Container(
        height: 120,
        width: 100,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade500,
              offset: Offset(5, 5),
              blurRadius: 15,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: isDarkMode ? Colors.grey.shade800 : Colors.white,
              offset: Offset(-5, -5),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: (isDarkMode ? Colors.white : Colors.grey),
                size: 35,
              ),
              SizedBox(height: 5),
              Text(
                text,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
