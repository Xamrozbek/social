import 'package:flutter/material.dart';

class MenuItems extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function()? onTap;

  const MenuItems({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            color: Theme.of(context).colorScheme.primary,
            height: 50,
            child: Row(children: [Icon(icon), Text(text)]),
          ),
        ),
      ],
    );
  }
}
