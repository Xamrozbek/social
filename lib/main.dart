import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social/auth/auth_page.dart';

import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:social/themes/dark_mode.dart';
import 'package:social/themes/light_mode.dart';
import 'package:social/themes/theme_provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
