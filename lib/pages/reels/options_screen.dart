import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OptionsScreen extends StatefulWidget {
  @override
  State<OptionsScreen> createState() => _OptionsScreenState();


}

class _OptionsScreenState extends State<OptionsScreen> {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 110),
                  Row(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.black,
                        ),
                        radius: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'flutter_developer02',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.verified, size: 15, color: Colors.white),
                      SizedBox(width: 6),
                      Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Follow',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Flutter is beautiful and fast 💙❤💛 ..',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.music_note, size: 15, color: Colors.white),
                      Text(
                        'Original Audio - some music track--',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                children: [
                  Column(
                    children: [
                      Icon(FontAwesomeIcons.heart, color: Colors.white),
                      SizedBox(height: 3),
                      Text('0', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Icon(FontAwesomeIcons.comment, color: Colors.white),
                      SizedBox(height: 3),
                      Text('0', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Icon(FontAwesomeIcons.paperPlane, color: Colors.white),
                      SizedBox(height: 3),
                      Text('0', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 60),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
