import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../pages/home_page.dart' show HomePage;
import 'login_or_register.dart';
import 'chat/chat_service.dart'; // ChatService import

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Foydalanuvchi chiqayotganida oflayn holatini yangilash
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _chatService.updateUserStatus(user.uid, false);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Foydalanuvchi ilovani yopayotganida oflayn holatini yangilash
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _chatService.updateUserStatus(user.uid, false);
      }
    } else if (state == AppLifecycleState.resumed) {
      // Foydalanuvchi ilovani qayta ochganida onlayn holatini yangilash
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _chatService.updateUserStatus(user.uid, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomePage();
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}