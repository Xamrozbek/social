import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:social/pages/reels/content_screen.dart'; // Assuming this is your video player widget
import '../../models/post.dart';

class VideoScreenPage extends StatefulWidget {
  final String initialVideoUrl;
  final List<Post> posts;

  const VideoScreenPage({
    super.key,
    required this.initialVideoUrl,
    required this.posts,
  });

  @override
  State<VideoScreenPage> createState() => _VideoScreenPageState();
}

class _VideoScreenPageState extends State<VideoScreenPage> {
  late List<String> videoUrls;

  @override
  void initState() {
    super.initState();
    videoUrls = _getVideoUrls();
  }

  List<String> _getVideoUrls() {
    final urls = <String>[widget.initialVideoUrl]; // Start with the initial URL
    for (final post in widget.posts) {
      if (post.mediaType == 'video' &&
          post.mediaURLs != null &&
          post.mediaURLs.isNotEmpty) {
        urls.addAll(post.mediaURLs.cast<String>()); // Safely add URLs
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              // Use PageView for better performance
              itemCount: videoUrls.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                // Add error handling here:
                if (index >= videoUrls.length || videoUrls[index].isEmpty) {
                  return const Center(child: Text('Error loading video'));
                }
                return ContentScreen(src: videoUrls[index]);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Shorts',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  // Icon(FontAwesomeIcons.t, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
