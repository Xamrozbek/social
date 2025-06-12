import 'package:flutter/material.dart';
import 'package:social/utilities/constants.dart';
import 'package:shimmer/shimmer.dart';

import '../../auth/auth_service.dart';
import '../../auth/chat/chat_service.dart';
import '../../components/user_tile.dart';
import '../../pages/chat_page.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 46,
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                query = value.toLowerCase().trim();
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search users...',
              border: InputBorder.none,
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
      body:
          query.isEmpty
              ? Center(child: Text('Search something by typing above'))
              : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _chatService.getUsersStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading users.'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmer();
                  }

                  final currentUserEmail = _authService.getCurrentUser()?.email;
                  final users = snapshot.data ?? [];

                  // Foydalanuvchilarni filtrlash: o'zini chiqarib tashlash + qidiruv
                  final filteredUsers =
                      users.where((user) {
                        final username =
                            user[Constants().USERNAME]
                                ?.toString()
                                .toLowerCase() ??
                            '';
                        final email =
                            user[Constants().EMAIL]?.toString().toLowerCase() ??
                            '';
                        final isNotCurrentUser =
                            user[Constants().EMAIL] != currentUserEmail;
                        final matchesQuery =
                            query.isEmpty ||
                            username.contains(query) ||
                            email.contains(query);
                        return isNotCurrentUser && matchesQuery;
                      }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(child: Text('No users found.'));
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final userData = filteredUsers[index];
                      return UserTile(
                        text: userData[Constants().USERNAME],
                        profileImageUrl:
                            userData[Constants().PROFILE_IMAGE_URL],
                        bio:
                            userData[Constants().BIO] ??
                            'The best gift is life',
                        isLoading: false,
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
                    },
                  );
                },
              ),
    );
  }

  // Yuklanayotgan paytda Shimmer
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder:
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100, height: 16, color: Colors.white),
                      const SizedBox(height: 5),
                      Container(width: 150, height: 14, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
