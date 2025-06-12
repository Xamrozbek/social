import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:social/ads/ads_tile.dart';
import 'package:social/pages/liked_page.dart';
import 'package:social/pages/notification_page.dart';
import 'package:social/pages/service_page.dart';
import 'package:social/util/bubble_stories.dart';
import 'package:social/util/user_posts.dart';
import '../auth/chat/chat_service.dart';
import '../components/my_icons_square.dart';
import '../models/post.dart';
import 'package:video_player/video_player.dart';

import '../utilities/constants.dart';

class UserHome extends StatefulWidget {
  UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final ChatService _chatService = ChatService();

  List<Post> posts = [];
  final ScrollController _controller = ScrollController();
  bool isLoading = false;

  late List<VideoPlayerController> _controllers;

  Future<void> _getPostsData() async {
    setState(() {
      isLoading = true;
    });
    List<Post> allPosts = await _chatService.getAllPosts(
      Constants().POSTS_COLLECTION,
    );
    allPosts.shuffle();
    posts = allPosts.take(12).toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getPostsData();
    _controller.addListener(() {
      if (_controller.position.atEdge &&
          _controller.position.pixels != 0 &&
          !isLoading) {
        fetch();
      }
    });
  }

  Future<void> fetch() async {
    if (isLoading) return; // Agar yuklanayotgan bo'lsa, qaytish
    setState(() {
      isLoading = true;
    });

    List<Post> allPosts = await _chatService.getAllPosts(
      Constants().POSTS_COLLECTION,
    );
    allPosts.shuffle();
    posts.addAll(allPosts.take(10)); // 10 ta yangi post qo'shish
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    await _getPostsData(); // Yangilanishda yangi postlar olish
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
  }

  List<String> people = ['Ali', 'John', 'Joe', 'Sem'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('TravelUz', style: TextStyle(fontWeight: FontWeight.w300)),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LikedPage()),
                    );
                  },
                  child: Icon(FontAwesomeIcons.heart, size: 20),
                ),
                SizedBox(width: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationPage(),
                      ),
                    );
                  },
                  child: Icon(FontAwesomeIcons.bell, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        height: 100,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        color: Colors.transparent,
        animSpeedFactor: 1,
        showChildOpacityTransition: false,
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
            children: [
              // STORIES
              // SizedBox(
              //   height: 120,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: people.length,
              //     itemBuilder: (context, index) {
              //       return BubbleStories(text: people[index]);
              //     },
              //   ),
              // ),
              SizedBox(height: 20),

              // ADS
              AdsTile(),

              Padding(
                padding: EdgeInsets.all(5),
                child: SizedBox(
                  height: 50,
                  child: ListView.builder(
                    itemCount: items.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ServicePage(
                                      collection:
                                          items[index]['collection'].toString(),
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 15,
                              ),
                              child: Row(
                                children: [
                                  Icon(items[index]['icon'], size: 20),
                                  SizedBox(width: 10),
                                  Text(items[index]['text']),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // POSTS
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0, right: 5, left: 5),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: posts.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == posts.length) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    }

                    var post = posts[index];

                    if (post.mediaType == 'image') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: UserPosts(
                          name: post.username,
                          pPicUrl: post.pPicUrl,
                          pic: post.mediaURLs.first,
                          likesCount: post.likesCount.toString(),
                          commentCount: post.commentsCount.toString(),
                          content: post.content,
                          time: post.timestamp,
                          mediaUrls: post.mediaURLs,
                          mediaType: post.mediaType,
                          saved: post.saved,
                          send: post.send,
                        ),
                      );
                    }

                    return SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> items = [
    {
      'text': 'Foods',
      'icon': Icons.fastfood,
      'collection': Constants().FOOD_COLLECTION,
    },
    {
      'text': 'Flights',
      'icon': Icons.flight_takeoff_rounded,
      'collection': Constants().FLIGHT_COLLECTION,
    },
    {
      'text': 'Auto',
      'icon': Icons.directions_car,
      'collection': Constants().AUTO_COLLECTION,
    },
    {
      'text': 'Hotels',
      'icon': FontAwesomeIcons.hotel,
      'collection': Constants().HOTEL_COLLECTION,
    },
    {
      'text': 'Tourguide',
      'icon': FontAwesomeIcons.solidMap,
      'collection': Constants().TOURGUIDE_COLLECTION,
    },
  ];
}
