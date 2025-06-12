import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social/models/post.dart';
import 'package:social/utilities/constants.dart';
import 'package:uuid/uuid.dart';
import '../enam/privacy_setting.dart';

class UploadAndDeleteService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  //upload media to firebase
  Future<void> uploadPost(
    String collection,
    String content,
    mediaType,
    List<String> mediaURLs,
    PrivacySetting privacySetting,
    String pPicUrl,
    String userName,
    String thumbnailImageUrl,
    String currentLocation,
    String email,
    BuildContext context,
  ) async {
    final Uuid uuid = Uuid();
    final String postID = uuid.v4();
    Post newPost = Post(
      pPicUrl: pPicUrl,
      username: userName,
      postID: postID,
      userID: _auth.currentUser!.uid,
      content: content,
      mediaURLs: mediaURLs,
      mediaType: mediaType,
      timestamp: Timestamp.now(),
      privacySetting: privacySetting,
      allowedUserIDs: [],
      saved: '0',
      send: '0',
      thumbnailImageUrl: thumbnailImageUrl,
      currentLocation: currentLocation,
      email: email,
    );

    try {
      await _firestore.collection(collection).doc(postID).set(newPost.toMap());
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Post yuklashda xato: $e')));
    }
  }

  //Delete post file from firebase
  Future<void> deleteFile(List<String> filePaths, String postId) async {
    try {
      for (String filePath in filePaths) {
        await _storage.ref(filePath).delete();
      }
      await _firestore
          .collection(Constants().POSTS_COLLECTION)
          .doc(postId)
          .delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
