import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'like_icon.dart';
import 'options_screen.dart';

class ContentScreen extends StatefulWidget {
  final String? src;

  const ContentScreen({Key? key, this.src}) : super(key: key);

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _liked = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    if (widget.src == null || widget.src!.isEmpty) {
      // Handle the case where src is null or empty
      setState(() {
        // Display an error message or a placeholder
      });
      return;
    }

    _videoPlayerController = VideoPlayerController.network(widget.src!);
    _videoPlayerController.addListener(() {
      setState(() {
        _isPlaying = _videoPlayerController.value.isPlaying;
      });
    });

    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        showControls: false,
        // Controls are handled manually
        looping: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
      );
      setState(() {});
    } catch (e) {
      print('Error initializing video: $e');
      // Handle the error appropriately (e.g., show an error message)
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? GestureDetector(
              onDoubleTap: () {
                setState(() {
                  _liked = !_liked;
                });
              },
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                      });
                      if (_isPlaying) {
                        _videoPlayerController.play();
                      } else {
                        _videoPlayerController.pause();
                      }
                    },
                    child: Chewie(controller: _chewieController!),
                  ),
                ],
              ),
            )
            : Center(
              // Improved loading indicator
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 10),
                  Text('Loading...', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
        if (_liked) Center(child: LikeIcon()), // Added const
        OptionsScreen(), // Added const
      ],
    );
  }
}
