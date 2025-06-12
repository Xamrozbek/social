import 'package:cloud_firestore/cloud_firestore.dart';

import '../enam/privacy_setting.dart';

class Post {
  final String postID;
  final String userID;
  final String username;
  final String pPicUrl;
  final String content;
  final List<String> mediaURLs;
  final String mediaType; // MediaType enum
  final Timestamp timestamp;
  final int likesCount;
  final int commentsCount;
  final PrivacySetting privacySetting; // Yangi xususiyat enum sifatida
  final List<String> allowedUserIDs;
  final String saved;
  final String send;
  final String thumbnailImageUrl;
  final String currentLocation;
  final String email;

  Post({
    required this.postID,
    required this.userID,
    required this.content,
    required this.mediaURLs,
    required this.mediaType, // MediaType
    required this.timestamp,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.privacySetting, // Yangi xususiyat
    required this.allowedUserIDs,
    required this.username,
    required this.pPicUrl,
    required this.saved,
    required this.send,
    required this.thumbnailImageUrl,
    required this.currentLocation,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'postID': postID,
      'userID': userID,
      'username': username,
      'pPicUrl': pPicUrl,
      'content': content,
      'mediaURLs': mediaURLs,
      'mediaType': mediaType,
      'privacySetting':
          privacySetting
              .toString()
              .split('.')
              .last, // PrivacySetting enum qiymatini stringga o'zgartirish
      'timestamp': timestamp,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'allowedUserIDs': allowedUserIDs,
      'saved': saved,
      'send': send,
      'thumbnailImageUrl': thumbnailImageUrl,
      'currentLocation': currentLocation,
      'email':email
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      pPicUrl: map['pPicUrl'],
      username: map['username'],
      postID: map['postID'],
      userID: map['userID'],
      content: map['content'],
      mediaURLs: List<String>.from(map['mediaURLs']),
      mediaType: map['mediaType'],
      // MediaType enum qiymatini olish
      privacySetting: PrivacySetting.values.firstWhere(
        (e) => e.toString().split('.').last == map['privacySetting'],
      ),
      // PrivacySetting enum qiymatini olish
      timestamp: map['timestamp'],
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      allowedUserIDs: List<String>.from(map['allowedUserIDs'] ?? []),
      saved: map['saved'],
      send: map['send'],
      thumbnailImageUrl: map['thumbnailImageUrl'],
      currentLocation: map['currentLocation'],
      email: map['email']
    );
  }
}
