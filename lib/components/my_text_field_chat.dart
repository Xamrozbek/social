import 'package:flutter/material.dart';

class MyTextFieldChat extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final FocusNode? focusNode;
  final bool isVisible;

  const MyTextFieldChat({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.focusNode,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary, // Foni uchun rang
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary, // Chegara rangini belgilash
            width: 1.5, // Chegara qalinligi
          ),
        ),
        child: Row(
          children: [
            Expanded(
              // TextField kengayadi
              child: TextField(
                obscureText: obscureText,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  border: InputBorder.none, // Chegarani olib tashlaymiz
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0,
                  ), // Ichki to'siq
                ),
              ),
            ),
            Visibility(
              visible: isVisible,
              child: Transform.rotate(
                angle: 45 * (3.141592653589793238 / 180), // 45 gradusni radianlarga aylantirish
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Icon(
                    Icons.attach_file,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}