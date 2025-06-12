import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social/models/post.dart';
import 'package:social/pages/full_screen_page.dart';
import 'package:social/pages/reels/video_screen_page.dart';
import 'package:social/pages/search_page.dart';
import '../auth/chat/chat_service.dart';
import '../utilities/constants.dart';

class UserSearch extends StatefulWidget {
  UserSearch({super.key});

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  final ChatService _chatService = ChatService();
  TextEditingController searchController = TextEditingController();
  List<Post> posts = [];
  List<Post> allPosts = [];
  final _controller = ScrollController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getPostsData();
    _controller.addListener(() {
      if (_controller.position.atEdge && _controller.position.pixels != 0) {
        fetch();
      }
    });
  }

  Future<void> _getPostsData() async {
    List<Post> allPosts = await _chatService.getAllPosts(Constants().POSTS_COLLECTION);
    allPosts.shuffle(); // Tasodifiy tartibda joylashtirish
    posts = allPosts.take(12).toList(); // Faqat 12 ta post olish
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetch() async {
    if (isLoading) return; // Agar yuklanayotgan bo'lsa, qaytish
    setState(() {
      isLoading = true;
    });

    allPosts = await _chatService.getAllPosts(Constants().POSTS_COLLECTION);
    allPosts.shuffle();
    posts.addAll(allPosts.take(10)); // 10 ta yangi post qo'shish
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1));
    await _getPostsData(); // Yangilanishda yangi postlar olish
  }

  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 45, left: 8.0, right: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      );
                    },
                    child: Container(
                      height: 46,
                      padding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Search...'), Icon(Icons.search)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Column(
            children: [
              Expanded(
                child: LiquidPullToRefresh(
                  onRefresh: _handleRefresh,
                  height: 100,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  color: Colors.transparent,
                  animSpeedFactor: 1,
                  showChildOpacityTransition: false,
                  child: MasonryGridView.builder(
                    controller: _controller,
                    itemCount: posts.length + (isLoading ? 1 : 0),
                    // Yuklanayotgan indikator
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                    itemBuilder: (context, index) {
                      if (index == posts.length) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        );
                      }
                      final post = posts[index];
                      String? mediaUrl;
                      String? thumbnailImageUrl;
                      if (post.mediaURLs.isNotEmpty) {
                        mediaUrl = post.mediaURLs.first;
                      }
                      if (post.thumbnailImageUrl.isNotEmpty) {
                        thumbnailImageUrl = post.thumbnailImageUrl;
                      }

                      return Column(
                        children: [
                          Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 5.0,
                                  right: 2,
                                  left: 2,
                                ),
                                //--------------
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => FullScreenPage(
                                              url: mediaUrl.toString(),
                                              posts: posts,
                                              mediaType: post.mediaType,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      post.mediaType == 'image'
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: mediaUrl.toString(),
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, url) =>
                                                      buildShimmerPlaceholder(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          )
                                          : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  thumbnailImageUrl.toString(),
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, url) =>
                                                      buildShimmerPlaceholder(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Icon(
                                          post.mediaType == 'image'
                                              ? FontAwesomeIcons.image
                                              : FontAwesomeIcons.youtube,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Positioned(
                                left: 10,
                                top: 10,
                                child:
                                    post.mediaURLs.length > 1
                                        ? const Icon(
                                          CupertinoIcons
                                              .rectangle_fill_on_rectangle_fill,
                                          size: 15,
                                          color: Colors.white,
                                        )
                                        : Container(),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10.0,
                              right: 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Icon(Icons.more_horiz)],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
