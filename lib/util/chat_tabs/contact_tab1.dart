import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:social/components/user_tile_contact.dart';
import 'package:social/utilities/constants.dart';
import 'package:shimmer/shimmer.dart';

import '../../auth/auth_service.dart';
import '../../auth/chat/chat_service.dart';
import '../../pages/chat_page.dart';

class ContactTab1 extends StatelessWidget {
  ContactTab1({super.key});

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
    final currentUserID = _authService.getCurrentUser()!.uid;
    final currentUserEmail = _authService.getCurrentUser()!.email;

    // `receiver_ids` ni olish va to'g'ri turga o'tkazish
    List<String>? receiverIDs =
        (userData[Constants().RECEIVER_IDS] as List<dynamic>?)
            ?.map((id) => id as String)
            .toList() ??
        [];

    // Agar joriy foydalanuvchi ID receiver_ids ro'yhatida bo'lsa va email o'ziga teng bo'lmasa
    if (receiverIDs != null &&
        receiverIDs.contains(currentUserID) &&
        userData[Constants().EMAIL] != currentUserEmail) {
      final lastMessageDataList = userData[Constants().LAST_MESSAGE_AND_TIME];

      String? lastMessage;
      Timestamp? lastTimestamp;

      // lastMessageDataList ni tekshirish
      if (lastMessageDataList is List) {
        for (var messageData in lastMessageDataList) {
          if (messageData is Map<String, dynamic>) {
            final receiverId = messageData[Constants().SENDER_ID];

            // Agar receiverID teng bo'lsa
            if (receiverId == currentUserID) {
              lastMessage = messageData[Constants().MESSAGE] ?? 'No message';
              lastTimestamp = messageData[Constants().TIMESTAMP] as Timestamp?;
              print(lastMessage);
              print(lastTimestamp);
              break; // Birinchi mos kelganini topganimizdan keyin to'xtatamiz
            }
          }
        }
      }

      return UserTileContact(
        text: userData[Constants().USERNAME],
        profileImageUrl: userData[Constants().PROFILE_IMAGE_URL],
        lastMessage: lastMessage.toString(),
        isLoading: false,
        isOnline: userData[Constants().IS_ONLINE] ?? false,
        lastTime: lastTimestamp != null ? formatTimestamp(lastTimestamp) : '',
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
      return Container(); // Agar joriy foydalanuvchi ID receiver_ids ro'yhatida bo'lmasa yoki email o'ziga teng bo'lsa, bo'sh konteyner
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm a').format(dateTime); // Soat va daqiqa
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
