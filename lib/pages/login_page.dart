import 'package:flutter/material.dart';
import 'package:social/components/aquare_tile.dart';
import 'package:social/components/my_button.dart';
import 'package:social/components/my_textfield.dart';

import '../auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  void login(BuildContext context) async {
    final authService = AuthService();
    try {
      authService.signInWithEmailPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 54,
                    width: 54,
                    child: Image.asset('assets/logo.png'),
                  ),
                  SizedBox(height: 25),
                  Text(
                    'Sign in your account',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7870DB),
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(height: 25),

                  MyTextField(
                    title: 'Email',
                    hintText: 'ex: jon.smith@email.com',
                    obscureText: false,
                    controller: emailController,
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    title: 'Password',
                    hintText: '******',
                    obscureText: true,
                    controller: passwordController,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5),
                    child: GestureDetector(
                      child: Container(
                        height: 46,
                        child: MyButton(text: 'SIGN IN'),
                      ),
                      onTap: () {
                        login(context);
                      },
                    ),
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(onTap: () {}, imagePath: 'assets/google.png'),
                      const SizedBox(width: 15),
                      SquareTile(onTap: () {}, imagePath: 'assets/apple.png'),
                    ],
                  ),
                  SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Don\'t have an account?'),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
