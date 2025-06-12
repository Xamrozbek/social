import 'package:flutter/material.dart';
import 'package:social/ability/full_circular_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserTileContact extends StatefulWidget {
  final String text;
  final String lastMessage;
  final String profileImageUrl;
  final void Function()? onTap;
  final bool isLoading;
  final bool isOnline; // Yangi parametr
  final String lastTime;

  const UserTileContact({
    super.key,
    required this.text,
    required this.onTap,
    required this.profileImageUrl,
    required this.lastMessage,
    this.isLoading = true,
    this.isOnline = false,
    required this.lastTime, // Standart qiymat
  });

  @override
  State<UserTileContact> createState() => _UserTileContactState();
}

class _UserTileContactState extends State<UserTileContact> {
  String formatText(String text) {
    if (text.length <= 14) {
      return text;
    }
    return '${text.substring(0, 21)}...';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(.2),
          borderRadius: BorderRadius.circular(2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 20),
        padding: const EdgeInsets.all(10),
        child: _buildUserInfo(),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullCircularImage(
                  url: widget.profileImageUrl,
                  text: widget.text,
                ),
              ),
            );
          },
          child: Hero(
            tag: widget.profileImageUrl, // Hero tagi
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: widget.profileImageUrl.toString(),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.person, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(formatText(widget.text))),
                  Text(widget.lastTime),
                ],
              ),
              Text(formatText(widget.lastMessage)),
            ],
          ),
        ),
      ],
    );
  }
}