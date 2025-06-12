import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              // color:
              //     isCurrentUser
              //         ? (isDarkMode ? Colors.green.shade600 : Colors.grey.shade500)
              //         : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
              gradient:
                  isCurrentUser
                      ? LinearGradient(
                        colors: [
                          Colors.blue.shade900, // Yuqori chap rang
                          Colors.purple, // Past o'ng rang
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : LinearGradient(
                        colors: [Colors.blue.shade100, Colors.blue.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              borderRadius:
                  isCurrentUser
                      ? BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      )
                      : BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
            ),
            margin: EdgeInsets.symmetric(
              vertical: 2,
              horizontal:
                  isCurrentUser ? 2 : 20, // Current user bo'lsa 20, aks holda 5
            ).copyWith(
              left:
                  isCurrentUser ? 20 : 2, // Current user bo'lsa 5, aks holda 20
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              message,
              style: TextStyle(
                color:
                    isCurrentUser
                        ? Colors.white
                        : (isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ),
          Text(
            timestamp,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
