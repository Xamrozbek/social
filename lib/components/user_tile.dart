import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String bio;
  final String profileImageUrl;
  final void Function()? onTap;
  final bool isLoading;

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    required this.profileImageUrl,
    required this.bio,
    this.isLoading = true,
  });

  String formatText(String text) {
    if (text.length <= 14) {
      return text;
    }
    return '${text.substring(0, 21)}...';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(.2),
          borderRadius: BorderRadius.circular(2),
        ),
        margin: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
        padding: EdgeInsets.all(10),
        child: _buildUserInfo(),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            profileImageUrl.toString(),
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(child: CircularProgressIndicator());
            },
            errorBuilder:
                (context, error, stackTrace) => Icon(Icons.person, size: 40),
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(formatText(text)), Text(formatText(bio))],
        ),
      ],
    );
  }
}
