import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:social/components/my_comment.dart';
import 'package:video_player/video_player.dart';

class UserPosts extends StatefulWidget {
  final String name;
  final String pPicUrl;
  final String pic;
  final String likesCount;
  final String commentCount;
  final String content;
  final Timestamp time;
  final String mediaType;
  final List<String> mediaUrls;
  final String saved;
  final String send;

  UserPosts({
    super.key,
    required this.name,
    required this.pPicUrl,
    required this.pic,
    required this.likesCount,
    required this.commentCount,
    required this.content,
    required this.time,
    required this.mediaUrls,
    required this.mediaType,
    required this.saved,
    required this.send,
  });

  @override
  State<UserPosts> createState() => _UserPostsState();
}

class _UserPostsState extends State<UserPosts> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(widget.mediaUrls.first);
    await _videoController.initialize();
    _videoController.setLooping(true); // Video takrorlanadi
    _videoController.play(); // Video avtomatik o'ynaydi
  }

  @override
  void dispose() {
    _videoController.pause();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _videoController.value.isPlaying
          ? _videoController.pause()
          : _videoController.play();
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('dd-MMMM yyyy').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    //profile pic
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl:
                              widget.pPicUrl.toString().isNotEmpty
                                  ? widget.pPicUrl.toString()
                                  : 'default_image_url',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.person, size: 40),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              formatTimestamp(widget.time),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.more_vert),
                ),
              ],
            ),
            (widget.mediaType == 'image')
                ? Container(
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.mediaUrls.first,
                        width: double.infinity,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
                :
            SizedBox(
                  height: 500,
                  width: double.infinity,
                  child: GestureDetector(
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
                ),

            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Icon(FontAwesomeIcons.heart, size: 18),
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.likesCount,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              MyComment().showCommentBottomSheet(context);
                            },
                            child: Icon(FontAwesomeIcons.comment, size: 18),
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.commentCount,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.bookmark, size: 18),
                          SizedBox(width: 10),
                          Text(
                            widget.saved,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Row(
                      children: [
                        Icon(FontAwesomeIcons.paperPlane, size: 18),
                        SizedBox(width: 8),
                        Text(
                          widget.send,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            //Caption
            Padding(
              padding: const EdgeInsets.only(right: 8, left: 15, bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        children: [
                          TextSpan(
                            text: '${widget.name} ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: widget.content),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
