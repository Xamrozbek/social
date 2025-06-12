import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social/pages/search_page.dart';
import 'package:social/pages/view_service_item_page.dart';

import '../auth/auth_service.dart';
import '../auth/chat/chat_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../local_db/UserPreferences.dart';
import '../models/post.dart';
import '../utilities/constants.dart';

class ServicePage extends StatefulWidget {
  final String collection;

  const ServicePage({super.key, required this.collection});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final AuthService _auth = AuthService();
  final ChatService _chatService = ChatService();
  String? username;
  String? profileImageUrl;
  String? bio;
  String? email;
  String? phoneNumber;
  int postCount = 0;
  bool isLoading = true; // Yuklanayotganligini kuzatish uchun
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataFromPrefs(); // Avval ma'lumotlarni yuklaymiz
    _getPostsData();
  }

  Future<void> _getPostsData() async {
    List<Post> allPosts = await _chatService.getAllPosts(widget.collection);
    allPosts.shuffle(); // Tasodifiy tartibda joylashtirish
    posts = allPosts.take(20).toList(); // Faqat 12 ta post olish
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadUserDataFromPrefs() async {
    final userData = await UserPreferences.loadUserData();
    setState(() {
      username = userData['username'];
      profileImageUrl = userData['profileImageUrl'];
      bio = userData['bio'];
      email = userData['email'];
      phoneNumber = userData['phoneNumber'];
      isLoading = username == null;
    });

    if (username == null) {
      await _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final userID = _auth.getCurrentUser()!.uid.toString();
    final userDataFuture = _chatService.getUserData(userID);
    final postCountFuture = _chatService.getUserPosts(userID);

    final snapshot = await userDataFuture;
    final posts = await postCountFuture;

    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      setState(() {
        profileImageUrl = userData[Constants().PROFILE_IMAGE_URL];
        username = userData[Constants().USERNAME];
        bio = userData[Constants().BIO];
        email = userData[Constants().EMAIL];
        phoneNumber = userData[Constants().PHONE_NUMBER];
        postCount = posts.length;
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

  String formatText(String text) {
    if (text.length <= 14) {
      return text;
    }
    return '${text.substring(0, 18)}...';
  }

  TextEditingController searchController = TextEditingController();
  String query = '';

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    String formattedDate = DateFormat('EEEE, d MMMM').format(now);
    String month = DateFormat('MMMM').format(now);
    return Scaffold(
      body:
          posts.isEmpty
              ? Center(child: Text('Data not found yet!'))
              : NestedScrollView(
                headerSliverBuilder: (
                  BuildContext context,
                  bool innerBoxIsScrolled,
                ) {
                  return <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                          top: 50,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(formattedDate.toString()),
                                      Text(
                                        'Hello $username',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: profileImageUrl.toString(),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                      errorWidget:
                                          (context, url, error) => const Icon(
                                            Icons.person,
                                            size: 40,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 46,
                                  padding: EdgeInsets.only(
                                    left: 10,
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Search...'),
                                        Icon(Icons.search),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Popular',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 400,
                              width: double.infinity,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: posts.length,
                                itemBuilder: (context, index) {
                                  final post = posts[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0,
                                      vertical: 10,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    ViewServiceItemPage(
                                                      post: post,
                                                    ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: 400,
                                        width: 250,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                        child: Stack(
                                          children: [
                                            SizedBox(
                                              height: 300,
                                              width: 250,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                                child: Image.network(
                                                  post.mediaURLs.first,
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 60,
                                              left: 10,
                                              right: 10,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      ClipOval(
                                                        child: CachedNetworkImage(
                                                          imageUrl:
                                                              post.pPicUrl,
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => const Icon(
                                                                Icons.person,
                                                                size: 40,
                                                              ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        post.username,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 25,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(.5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            15,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      CupertinoIcons
                                                          .location_solid,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              left: 10,
                                              right: 10,
                                              top: 320,
                                              child: Text(
                                                post.content,
                                                overflow: TextOverflow.visible,
                                                maxLines: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Explore more',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            // Text('See all', style: TextStyle(color: Colors.blue)),
                          ],
                        ),
                      ),
                      ListView.builder(
                        itemCount: posts.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 5,
                            ),
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 5),
                                  SizedBox(
                                    height: 130,
                                    width: 110,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        post.mediaURLs.first,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 10,
                                      ),
                                      child: Column(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.username,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            post.content,
                                            style: TextStyle(),
                                            overflow: TextOverflow.visible,
                                            maxLines: 4,
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
