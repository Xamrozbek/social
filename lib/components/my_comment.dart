import 'package:flutter/material.dart';

class MyComment extends StatelessWidget {
  const MyComment({super.key});

  void showCommentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return MyComment();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Text(
                'Comment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // O'lchamni qo'shish
                ),
              ),
            ),
          ),
          Expanded(child: Center(child: Text('No comments yet!'))),
        ],
      ),
    );
  }
}
