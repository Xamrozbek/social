import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social/components/my_comment.dart';
import 'package:social/models/post.dart';
import 'package:video_player/video_player.dart'
    show VideoPlayer, VideoPlayerController;

class FullScreenPage extends StatefulWidget {
  FullScreenPage({
    super.key,
    required this.url,
    required this.posts,
    required this.mediaType,
  });

  final String url;
  final String mediaType;
  List<Post> posts;

  @override
  State<FullScreenPage> createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  late PageController _pageController;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initializeVideo();
  }

  void _togglePlayPause() {
    setState(() {
      _videoController.value.isPlaying
          ? _videoController.pause()
          : _videoController.play();
    });
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.url);
    await _videoController.initialize();
    _videoController.setLooping(true);
    _videoController.play();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(right: 5.0, left: 5, top: 40, bottom: 5),
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey,
                      ),
                      child:
                          widget.mediaType == 'image'
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  widget.url,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: GestureDetector(
                                  onTap: _togglePlayPause,
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: VideoPlayer(_videoController),
                                  ),
                                ),
                              ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.heart, size: 20),
                                    SizedBox(width: 8),
                                    Text('0', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        MyComment().showCommentBottomSheet(
                                          context,
                                        );
                                      },
                                      child: Icon(
                                        FontAwesomeIcons.comment,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('0', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.paperPlane, size: 20),
                                    SizedBox(width: 8),
                                    Text('0', style: TextStyle(fontSize: 16)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(FontAwesomeIcons.ellipsis, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF84D3FC), Color(0xFF7870DB)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: Column(
            children: [
              Expanded(
                child: MasonryGridView.builder(
                  itemCount: widget.posts.length,
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    if (index == widget.posts.length) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      );
                    }
                    final post = widget.posts[index];
                    String? mediaUrl, thumbnailImageUrl;
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
                                            posts: widget.posts,
                                            mediaType: post.mediaType,
                                          ),
                                    ),
                                  );
                                  _videoController.pause();
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
                                      ? Icon(
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
