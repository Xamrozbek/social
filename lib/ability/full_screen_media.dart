import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'
    show VideoPlayer, VideoPlayerController;

import '../components/my_icons_square.dart';

class FullScreenMedia extends StatefulWidget {
  final List<String> mediaUrls;

  const FullScreenMedia({super.key, required this.mediaUrls});

  @override
  _FullScreenMediaState createState() => _FullScreenMediaState();
}

class _FullScreenMediaState extends State<FullScreenMedia> {
  late PageController _pageController;
  late VideoPlayerController _videoController;

  final int _currentIndex = 0;

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
    _videoController = VideoPlayerController.network(widget.mediaUrls.first);
    await _videoController.initialize();
    _videoController.setLooping(true); // Video takrorlanadi
    _videoController.play(); // Video avtomatik o'ynaydi
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildVideoScreen(),
            SizedBox(height: 20),

            _buildIndicator(),
            SizedBox(height: 20),
            _buildReaction(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoScreen() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(_videoController),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReaction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            MyIconsSquare(
              iconPath: 'assets/icons/favorite.png',
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Text('28'),
          ],
        ),
        SizedBox(width: 20),
        Row(
          children: [
            MyIconsSquare(
              iconPath: 'assets/icons/comment.png',
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Text('28'),
          ],
        ),
        SizedBox(width: 20),
        Row(
          children: [
            MyIconsSquare(
              iconPath: 'assets/icons/send.png',
              color: Colors.grey,
            ),
            SizedBox(width: 10),
            Text('28'),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.mediaUrls.length, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index ? Colors.white : Colors.grey,
            ),
          );
        }),
      ),
    );
  }
}
