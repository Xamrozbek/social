import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../components/my_icons_square.dart';

class FullScreenImage extends StatefulWidget {
  final List<String> photos;

  const FullScreenImage({super.key, required this.photos});

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Orqaga qaytish
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SizedBox(height: 20),
            Expanded(
              child: PhotoViewGallery.builder(
                itemCount: widget.photos.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(widget.photos[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(
                      tag: widget.photos[index],
                    ),
                  );
                },
                scrollPhysics: BouncingScrollPhysics(),
                backgroundDecoration: BoxDecoration(color: Colors.black),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
            _buildIndicator(),
            SizedBox(height: 20),
            _buildReaction(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReaction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.heart, size: 18, color: Colors.white),
            SizedBox(width: 10),
            Text('28', style: TextStyle(color: Colors.white)),
          ],
        ),
        SizedBox(width: 20),

        Row(
          children: [
            Icon(FontAwesomeIcons.comment, size: 18, color: Colors.white),
            SizedBox(width: 10),
            Text('28', style: TextStyle(color: Colors.white)),
          ],
        ),
        SizedBox(width: 20),

        Row(
          children: [
            Icon(FontAwesomeIcons.paperPlane, size: 18, color: Colors.white),
            SizedBox(width: 10),
            Text('28', style: TextStyle(color: Colors.white)),
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
        children: List.generate(widget.photos.length, (index) {
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
