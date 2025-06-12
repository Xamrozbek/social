import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social/ability/full_screen_media.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import '../../auth/auth_service.dart';
import '../../auth/chat/chat_service.dart';
import '../../models/post.dart';

class AccountTab2 extends StatefulWidget {
  const AccountTab2({super.key});

  @override
  State<AccountTab2> createState() => _AccountTab2State();
}

class _AccountTab2State extends State<AccountTab2> {
  final ChatService _chatService = ChatService();
  final AuthService _auth = AuthService();
  List<Post> posts = [];
  Map<String, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _getUserPostData();
  }

  Future<void> _getUserPostData() async {
    final userID = await _auth.getCurrentUser()?.uid;
    posts = await _chatService.getUserPosts(userID.toString());
    print("Posts: $posts");
    setState(() {});
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  VideoPlayerController _getController(String url) {
    if (!_controllers.containsKey(url)) {
      final controller = VideoPlayerController.network(url)
        ..initialize().then((_) {
          if (mounted) setState(() {});
        });
      _controllers[url] = controller;
    }
    return _controllers[url]!;
  }

  compressVideoFile(String videoFilePath) async {
    final compressVideoFilePath = await VideoCompress.compressVideo(
      videoFilePath,
      quality: VideoQuality.LowQuality,
    );
    return compressVideoFilePath!.file;
  }

  getThumbnailImage(String videoFilePath) async {
    final thumbnailImage = await VideoCompress.getMediaInfo(videoFilePath);
    return thumbnailImage;
  }

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Center(child: Text('No posts available!'));
    }
    return MasonryGridView.builder(
      gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        String? thumbnailImageUrl;

        if (post.mediaType == 'video' && post.mediaURLs.isNotEmpty) {
          thumbnailImageUrl = post.thumbnailImageUrl;
        }

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child:
              thumbnailImageUrl != null
                  ? Hero(
                    tag: thumbnailImageUrl,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FullScreenMedia(
                                      mediaUrls: post.mediaURLs,
                                    ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: thumbnailImageUrl,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => _buildVideoThumbnail(
                                    thumbnailImageUrl.toString(),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.error,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            FontAwesomeIcons.youtube,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                post.likesCount.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  : Center(child: SizedBox(height: .1)),
        );
      },
    );
  }

  Widget _buildVideoThumbnail(String url) {
    final controller = _getController(url);
    return controller.value.isInitialized
        ? VideoPlayer(controller)
        : Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            color: Colors.grey, // Placeholder color
          ),
        );
  }
}
