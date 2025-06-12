import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:social/auth/upload_and_delete_service.dart';
import 'package:social/util/toast_message.dart';
import '../../ability/full_screen_image.dart';
import '../../auth/auth_service.dart';
import '../../auth/chat/chat_service.dart';
import '../../models/post.dart';

class AccountTab1 extends StatefulWidget {
  const AccountTab1({super.key});

  @override
  State<AccountTab1> createState() => _AccountTab1State();
}

class _AccountTab1State extends State<AccountTab1> {
  final ChatService _chatService = ChatService();
  final AuthService _auth = AuthService();
  final ToastMessage toastMessage = ToastMessage();

  final UploadAndDeleteService _uploadAndDeleteService =
      UploadAndDeleteService();
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _getUserPostData();
  }

  Future<void> _getUserPostData() async {
    final userID = await _auth.getCurrentUser()?.uid;
    posts = await _chatService.getUserPosts(userID.toString());
    print("Posts: $posts"); // Posts ro'yxatini chiqarish
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.builder(
      itemCount: posts.length,
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        final post = posts[index];
        String? imageUrl;

        if (post.mediaType == 'image' && post.mediaURLs.isNotEmpty) {
          imageUrl = post.mediaURLs[0];
        }

        return Padding(
          padding: const EdgeInsets.all(5.0),
          child:
              imageUrl != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        CupertinoContextMenu(
                          actions: <Widget>[
                            CupertinoContextMenuAction(
                              trailingIcon: CupertinoIcons.delete,
                              onPressed: () {
                                _uploadAndDeleteService
                                    .deleteFile(post.mediaURLs, post.postID)
                                    .then((_) {
                                      Navigator.pop(
                                        context,
                                      ); // O'chirishdan keyin menyuni yopish
                                      print(post.postID);
                                      toastMessage.show(
                                        'Post muvaffaqiyatli o\'chirildi${post.postID}',
                                      );
                                      setState(() {});
                                    })
                                    .catchError((e) {
                                      print(e.toString());
                                      Fluttertoast.showToast(
                                        msg: 'O\'chirishda xato: $e',
                                        fontSize: 16,
                                        gravity: ToastGravity.CENTER,
                                        backgroundColor: Colors.red.withOpacity(
                                          .5,
                                        ),
                                      );
                                    });
                              },
                              isDestructiveAction: true,
                              child: Text('Delete'),
                            ),
                          ],
                          enableHapticFeedback: false,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => FullScreenImage(
                                        photos: post.mediaURLs,
                                      ),
                                ),
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => _buildShimmerPlaceholder(),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.error,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            FontAwesomeIcons.image,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          left: 10,
                          top: 10,
                          child:
                              post.mediaURLs.length > 1
                                  ? const Icon(
                                    CupertinoIcons
                                        .rectangle_fill_on_rectangle_fill,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                  : Container(),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    post.likesCount.toString(),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  : const Center(child: SizedBox(height: .1)),
        );
      },
    );
  }

  // Shimmer effect as a separate method
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        color: Colors.grey, // Placeholder color
      ),
    );
  }
}
