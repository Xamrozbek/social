import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social/components/my_button.dart';
import 'package:social/components/my_textfield.dart';

import '../auth/auth_service.dart';
import '../components/aquare_tile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void register(BuildContext context) async {
    final _auth = AuthService();

    if (passwordController.text == confirmPasswordController.text) {
      if (_image == null) return;
      try {
        //upload profile image to firebase
        final ref = _storage.ref().child(
          'images/${DateTime.now().toIso8601String()}.jpg',
        );
        await ref.putFile(_image!);
        final url = await ref.getDownloadURL();
        print('Image uploaded: $url');

        _auth.signUpWithEmailPassword(
          emailController.text,
          passwordController.text,
          url,
          usernameController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(title: Text('Passwords don\'t match')),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sign up',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7870DB),
                            fontSize: 26,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child:
                                  _image == null
                                      ? Icon(
                                        Icons.camera,
                                        color: Color(0xFF7870DB),
                                        size: 25,
                                      )
                                      : ClipRRect(
                                        child: Image.file(
                                          _image!,
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  MyTextField(
                    title: 'Username',
                    hintText: 'ex: jon.smith',
                    obscureText: false,
                    controller: usernameController,
                  ),
                  SizedBox(height: 10),
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
                  SizedBox(height: 10),
                  MyTextField(
                    title: 'Confirm password',
                    hintText: '******',
                    obscureText: true,
                    controller: confirmPasswordController,
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 5,
                    ),
                    child: GestureDetector(
                      child: Container(
                        height: 46,
                        child: MyButton(text: 'SIGN UP'),
                      ),
                      onTap: () {
                        print("Sign Up button tapped");
                        register(context);
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                  SizedBox(height: 15),
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
                      Text('Have an account?'),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Login now',
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
