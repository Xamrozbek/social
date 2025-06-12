import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:social/pages/user_chat.dart';
import 'package:social/pages/user_home.dart';
import 'package:social/pages/user_profile.dart';
import 'package:social/pages/user_search.dart';
import 'package:social/pages/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _children = [
    UserHome(),
    UserSearch(),
    UserService(),
    UserChat(),
    UserProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GNav(
                backgroundColor: Theme.of(context).colorScheme.surface,
                color: Theme.of(context).colorScheme.inversePrimary,
                activeColor: Theme.of(context).colorScheme.secondary,
                tabBackgroundColor: Theme.of(context).colorScheme.primary,
                gap: 8,
                padding: EdgeInsets.all(10),
                tabs: [
                  GButton(icon: Icons.home, text: 'Home'),
                  GButton(icon: Icons.search, text: 'Search'),
                  GButton(icon: Icons.add, text: 'Service'),
                  GButton(icon: Icons.chat_rounded, text: 'Chat'),
                  GButton(icon: Icons.person, text: 'Profile'),
                ],
                onTabChange: onTabChange,
              );
            },
          ),
        ),
      ),
      body: _children[_selectedIndex],
    );
  }
}
