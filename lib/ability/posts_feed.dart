import 'package:flutter/material.dart';
import 'package:social/models/post.dart';
import 'package:social/utilities/constants.dart';

import '../auth/auth_service.dart';
import '../auth/chat/chat_service.dart';
import '../util/user_posts.dart';

class PostsFeed extends StatefulWidget {
  PostsFeed({super.key});

  @override
  State<PostsFeed> createState() => _PostsFeedState();
}

class _PostsFeedState extends State<PostsFeed> {
  final ChatService _chatService = ChatService();
  final AuthService _auth = AuthService();
  List<Post> posts = [];
  String? name;
  String? pPicUrl;

  @override
  void initState() {
    super.initState();
    _getUserPostData();
  }

  Future<void> _getUserPostData() async {
    final userID = await _auth.getCurrentUser()?.uid;
    if (userID != null) {
      posts = await _chatService.getUserPosts(userID);

      final snapshot = await _chatService.getUserData(userID);
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          name = userData[Constants().USERNAME];
          pPicUrl = userData[Constants().PROFILE_IMAGE_URL];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts'), backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];

            List<String> picUrls = [];
            if (post.mediaType == 'image' && post.mediaURLs.isNotEmpty) {
              picUrls = List.from(post.mediaURLs);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: UserPosts(
                name: name ?? 'Unknown',
                pPicUrl: pPicUrl ?? '',
                pic: picUrls.isNotEmpty ? picUrls.first : '',
                likesCount: post.likesCount.toString(),
                commentCount: post.commentsCount.toString(),
                content: post.content,
                time: post.timestamp,
                mediaUrls: picUrls,
                mediaType: post.mediaType,
                saved: post.saved,
                send: post.send,
              ),
            );
          },
        ),
      ),
    );
  }
}
