import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social/utilities/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  //sign in
  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      //sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user info already exists
      DocumentSnapshot snapshot = await _firestore
          .collection(Constants().USERS_COLLECTION)
          .doc(userCredential.user!.uid)
          .get();

      if (!snapshot.exists) {
        // save user info if it doesn't already exist
        await _firestore
            .collection(Constants().USERS_COLLECTION)
            .doc(userCredential.user!.uid)
            .set({
          Constants().UID: userCredential.user!.uid,
          Constants().EMAIL: email,
        });
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailPassword(
    String email,
    password,
    pfImageUrl,
    username,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      //save user info in a separate doc
      _firestore
          .collection(Constants().USERS_COLLECTION)
          .doc(userCredential.user!.uid)
          .set({
            Constants().UID: userCredential.user!.uid,
            Constants().EMAIL: email,
            Constants().PROFILE_IMAGE_URL: pfImageUrl,
            Constants().USERNAME: username,
          });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.toString());
    }
  }

  //sign out
  Future<void> signout() async {
    return await _auth.signOut();
  }
}
