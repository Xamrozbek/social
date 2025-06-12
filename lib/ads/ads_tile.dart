import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'AppData.dart';
import 'CustomImageViewer.dart';

class AdsTile extends StatefulWidget {
  const AdsTile({super.key});

  @override
  State<AdsTile> createState() => _AdsTileState();
}

class _AdsTileState extends State<AdsTile> {
  int myCurrentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Size size;
    double height;

    size = MediaQuery.of(context).size;
    height = size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              height: height * .20,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayInterval: const Duration(seconds: 2),
              enlargeCenterPage: true,
              aspectRatio: 2,
              onPageChanged: (index, reason) {
                setState(() {
                  myCurrentIndex = index;
                });
              },
            ),
            items:
                AppData.styleImages.map((imagePath) {
                  // Builder ni olib tashlang
                  return CustomImageViewer.show(
                    context: context,
                    url: imagePath,
                    fit: BoxFit.cover,
                  );
                }).toList(),
          ),

          SizedBox(height: 10),
          AnimatedSmoothIndicator(
            activeIndex: myCurrentIndex,
            count: AppData.styleImages.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              spacing: 10,
              dotColor: Theme.of(context).colorScheme.inversePrimary,
              activeDotColor: Colors.blue.shade400,
              paintStyle: PaintingStyle.fill,
            ),
          ),
        ],
      ),
    );
  }
}
