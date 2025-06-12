import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../auth/auth_service.dart';
import '../auth/chat/chat_service.dart';
import '../components/chat_bubble.dart';
import '../components/my_text_field_chat.dart';
import '../utilities/constants.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  FocusNode myFocusNode = FocusNode();

  //For Receiver
  String? profileImageUrl;
  String? userName;
  Timestamp? lastSeen;
  String? receiverUid;
  bool? isOnline;

  // ValueNotifier for icon state
  final ValueNotifier<IconData> _iconNotifier = ValueNotifier(Icons.mic);

  @override
  void initState() {
    super.initState();

    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(Duration(milliseconds: 500), () => scrollDown());
      }
    });

    Future.delayed(Duration(milliseconds: 500), () => scrollDown());

    _messageController.addListener(() {
      // only updating icon
      _iconNotifier.value =
          _messageController.text.isNotEmpty ? Icons.send : Icons.mic;
    });

    //Load Receiver data
    _loadReceiverData();
  }

  //Load Receiver Data
  Future<void> _loadReceiverData() async {
    try {
      final snapshot = await _chatService.getUserData(widget.receiverID);
      if (snapshot.exists) {
        final receiverData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          profileImageUrl = receiverData[Constants().PROFILE_IMAGE_URL];
          userName = receiverData[Constants().USERNAME];
          lastSeen = receiverData[Constants().LAST_SEEN];
          receiverUid = receiverData[Constants().UID];
          isOnline = receiverData[Constants().IS_ONLINE];
        });
      } else {
        print('Receiver data not found');
      }
    } catch (e) {
      print('Error loading receiver data: $e');
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime =
        timestamp.toDate(); // Timestampni DateTime ga o'zgartirish
    // Formatni aniqlash
    String formattedDate = DateFormat('MMMM dd, - hh:mm a').format(dateTime);
    return formattedDate;
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    // Resurslarni tozalash
    _iconNotifier.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
      );
      _chatService.lastMessageWithTime(
        _authService.getCurrentUser()!.uid.toString(),
        receiverUid.toString(),
        _messageController.text,
        DateTime.timestamp(),
      );

      print('pressed!');
      _messageController.clear(); // Xabar yuborilgach tozalash
      _iconNotifier.value = Icons.mic; // Yuborilgandan keyin ikona o'zgaradi
    }
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Row(
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
                    (context, error, stackTrace) =>
                        Icon(Icons.person, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName != null && userName!.isNotEmpty
                        ? userName.toString()
                        : 'Anonymous',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    (isOnline != false) ? 'online' : 'last seen recently',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.grey,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [Expanded(child: _buildMessageList()), _buildUserInput()],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID =
        _authService.getCurrentUser()?.uid ?? 'senderID not found!';
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text('Loading...'));
        }
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser =
        data[Constants().SENDER_ID] == _authService.getCurrentUser()?.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data[Constants().MESSAGE],
            isCurrentUser: isCurrentUser,
            timestamp: formatTimestamp(data[Constants().TIMESTAMP]),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextFieldChat(
              controller: _messageController,
              hintText: 'Type a message',
              obscureText: false,
              focusNode: myFocusNode,
              isVisible: false,
            ),
          ),
          Container(
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(right: 10),
            child: ValueListenableBuilder<IconData>(
              valueListenable: _iconNotifier,
              builder: (context, icon, child) {
                return IconButton(
                  onPressed: sendMessage,
                  icon: Icon(
                    icon, // Yangilangan icon
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
