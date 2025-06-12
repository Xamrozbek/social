import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social/ability/full_circular_image.dart';
import 'package:social/auth/auth_service.dart';
import 'package:social/components/my_button.dart';
import 'package:social/components/my_count_item.dart';
import 'package:social/models/post.dart';
import 'package:social/util/account_tabs/account_tab1.dart';
import 'package:social/util/account_tabs/account_tab2.dart';
import 'package:social/util/account_tabs/account_tab3.dart';
import 'package:social/util/account_tabs/account_tab4.dart';
import 'package:shimmer/shimmer.dart';
import '../auth/chat/chat_service.dart';
import '../local_db/UserPreferences.dart';
import '../utilities/constants.dart';

class UserProfile extends StatefulWidget {
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final AuthService _auth = AuthService();
  final ChatService _chatService = ChatService();

  String? username;
  String? profileImageUrl;
  String? bio;
  String? email;
  String? phoneNumber;

  int postCount = 0;
  bool isLoading = true; // Yuklanayotganligini kuzatish uchun

  @override
  void initState() {
    super.initState();
    _loadUserDataFromPrefs(); // Avval ma'lumotlarni yuklaymiz
  }

  Future<void> _loadUserDataFromPrefs() async {
    final userData =
        await UserPreferences.loadUserData(); // UserPreferences dan ma'lumotlarni yuklash
    setState(() {
      username = userData['username'];
      profileImageUrl = userData['profileImageUrl'];
      bio = userData['bio'];
      email = userData['email'];
      phoneNumber = userData['phoneNumber'];
      isLoading = username == null; // Agar username bo'lmasa yuklaymiz
    });

    if (username == null) {
      await _loadUserData(); // Agar ma'lumotlar mavjud bo'lmasa, yuklaymiz
    }
  }

  Future<void> _loadUserData() async {
    final userID = _auth.getCurrentUser()!.uid.toString();
    final userDataFuture = _chatService.getUserData(userID);
    final postCountFuture = _chatService.getUserPosts(userID); // Postlarni olish

    final snapshot = await userDataFuture;
    final posts = await postCountFuture; // Postlar olish

    // Ma'lumotlar bilan ishlash
    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      setState(() {
        profileImageUrl = userData[Constants().PROFILE_IMAGE_URL];
        username = userData[Constants().USERNAME];
        bio = userData[Constants().BIO];
        email = userData[Constants().EMAIL];
        phoneNumber = userData[Constants().PHONE_NUMBER];
        postCount = posts.length; // Postlar sonini yangilash
        isLoading = false;
      });

      await UserPreferences.saveUserData(
        username: username!,
        profileImageUrl: profileImageUrl!,
        bio: bio!,
        email: email!,
        phoneNumber: phoneNumber!,
      );
    }
  }



  void logout() {
    _auth.signout();
  }

  String formatText(String text) {
    if (text.length <= 14) {
      return text;
    }
    return '${text.substring(0, 18)}...';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                email != null ? formatText(email!) : 'ex: jon.smith@email.com',
                style: TextStyle(fontSize: 18),
              ),
              GestureDetector(
                onTap: logout,
                child: Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: isLoading ? _buildShimmer() : _buildProfile(),
                ),
              ),
            ];
          },
          body: Column(
            children: [
              TabBar(
                indicator: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(1),
                ),
                labelColor: Theme.of(context).colorScheme.inversePrimary,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Photos'),
                  Tab(text: 'Videos'),
                  Tab(text: 'Stories'),
                  Tab(text: 'Saved'),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TabBarView(
                    children: [
                      AccountTab1(),
                      AccountTab2(),
                      AccountTab3(),
                      AccountTab4(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[500]!,
      highlightColor: Colors.grey[300]!,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 90),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: 80,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    width: 150,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyCountItem(count: '...', text: 'Fans'),
              MyCountItem(count: '...', text: 'Following'),
              MyCountItem(count: '...', text: 'Posts'),
              MyCountItem(count: '...', text: 'Stories'),
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MyButton(text: 'Edit Profile'),
              SizedBox(width: 10),
              MyButton(text: 'Share Profile'),
            ],
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return Column(
      children: [
        Row(
          children: [
            ClipOval(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => FullCircularImage(
                            url: profileImageUrl ?? 'default_image_url',
                            text: username ?? 'No Username',
                          ),
                    ),
                  );
                },
                child: Hero(
                  tag: profileImageUrl ?? 'default_image_url',
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl:
                          profileImageUrl?.isNotEmpty == true
                              ? profileImageUrl!
                              : 'default_image_url',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) =>
                              const Icon(Icons.person, size: 70),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username ?? 'No Username',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  phoneNumber ?? '+998 91 155 31 93',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  bio ?? 'No bio available.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MyCountItem(count: '0', text: 'Fans'),
            MyCountItem(count: '0', text: 'Following'),
            MyCountItem(count: postCount.toString(), text: 'Posts'),
            MyCountItem(count: '0', text: 'Stories'),
          ],
        ),
        SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MyButton(text: 'Edit Profile'),
            SizedBox(width: 10),
            MyButton(text: 'Share Profile'),
          ],
        ),
        SizedBox(height: 25),
      ],
    );
  }
}
