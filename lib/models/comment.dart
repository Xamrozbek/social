import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String commentID;
  final String userID; // Komment yozgan foydalanuvchi
  final String content; // Komment matni
  final Timestamp timestamp; // Komment yozilgan vaqt
  final int likesCount; // Komment uchun yoqtirishlar soni
  final String postID; // Komment qilingan postning IDsi

  Comment({
    required this.commentID,
    required this.userID,
    required this.content,
    required this.timestamp,
    this.likesCount = 0,
    required this.postID,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentID': commentID,
      'userID': userID,
      'content': content,
      'timestamp': timestamp,
      'likesCount': likesCount,
      'postID': postID,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      commentID: map['commentID'],
      userID: map['userID'],
      content: map['content'],
      timestamp: map['timestamp'],
      likesCount: map['likesCount'] ?? 0,
      postID: map['postID'],
    );
  }
}