import 'package:flutter/material.dart';

class FullCircularImage extends StatelessWidget {
  final String url;
  final String text;

  const FullCircularImage({super.key, required this.url, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Orqaga qaytish
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: url, // Hero tagi
                child: ClipOval(
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    height: 250,
                    width: 250,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                text,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}