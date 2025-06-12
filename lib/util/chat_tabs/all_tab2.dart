import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social/utilities/constants.dart';
import 'package:shimmer/shimmer.dart';

import '../../auth/auth_service.dart';
import '../../auth/chat/chat_service.dart';
import '../../components/user_tile.dart';
import '../../pages/chat_page.dart';

class AllTab2 extends StatelessWidget {
  AllTab2({super.key});

  final ChatService _chatService = ChatService();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildUserList());
  }

  // Build a list of users except for the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // Error handling
        if (snapshot.hasError) {
          return Center(child: const Text('Error'));
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmer(); // Shimmer loading
        }

        // Check if data is available
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: const Text('No users found'));
        }

        // Return list view
        return ListView(
          children:
              snapshot.data!
                  .map<Widget>(
                    (userData) => _buildUserListItem(userData, context),
                  )
                  .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // Check if the user is not the current logged-in user
    if (userData[Constants().EMAIL] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData[Constants().USERNAME],
        profileImageUrl: userData[Constants().PROFILE_IMAGE_URL],
        bio: userData[Constants().BIO] ?? 'The best gift is life',
        isLoading: false,
        // Set this based on actual loading if needed
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    receiverEmail: userData[Constants().EMAIL],
                    receiverID: userData[Constants().UID],
                  ),
            ),
          );
        },
      );
    } else {
      return Container(); // Return an empty container for the current user
    }
  }

  // Shimmer effect for loading state
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5, // Number of shimmer items
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: [
                ClipOval(
                  child: Container(width: 40, height: 40, color: Colors.white),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 16, color: Colors.white),
                    SizedBox(height: 5),
                    Container(width: 150, height: 14, color: Colors.white),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
