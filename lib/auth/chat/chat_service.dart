import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:social/models/post.dart';

import '../../models/message.dart';
import '../../utilities/constants.dart';

class ChatService {
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //send message
  Future<void> sendMessage(String receiverID, String message) async {
    try {
      //get current user info
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final String currentUserID = user.uid;
      final String currentUserEmail = user.email ?? 'Email not found!';
      final Timestamp timestamp = Timestamp.now();

      //create a new message
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
      );

      //construct chat room ID for the two users (sorted to ensure uniqueness)
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      //add new message to database
      await _firestore
          .collection(Constants().DB_CHAT_ROOMS)
          .doc(chatRoomID)
          .collection(Constants().DB_MESSAGES)
          .add(newMessage.toMap());

      await addReceiverIDToUser(currentUserID, receiverID);
      await addReceiverIDToUser(currentUserID, currentUserID);
      await addUserIDToReceiver(receiverID, currentUserID);
      await addUserIDToReceiver(receiverID, receiverID);
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> addReceiverIDToUser(String userID, String receiverID) async {
    try {
      await _firestore
          .collection(Constants().USERS_COLLECTION)
          .doc(userID)
          .update({
            Constants().RECEIVER_IDS: FieldValue.arrayUnion([receiverID]),
          });
    } catch (e) {
      print('Error updating receiver_ids for user $userID: $e');
    }
  }

  Future<void> addUserIDToReceiver(String receiverID, String userID) async {
    try {
      await _firestore
          .collection(Constants().USERS_COLLECTION)
          .doc(receiverID)
          .update({
            Constants().RECEIVER_IDS: FieldValue.arrayUnion([userID]),
          });
    } catch (e) {
      print('Error updating receiver_ids for user $userID: $e');
    }
  }

  // Update User status
  void updateUserStatus(String userId, bool isOnline) {
    // Write to db
    FirebaseFirestore.instance
        .collection(Constants().USERS_COLLECTION)
        .doc(userId)
        .update({
          Constants().IS_ONLINE: isOnline,
          Constants().LAST_SEEN:
              isOnline ? FieldValue.serverTimestamp() : DateTime.now(),
        });
  }

  //last message and time saver
  void lastMessageWithTime(
    String userId,
    String receiverId,
    String lastMessage,
    DateTime timestamp,
  ) async {
    final usersCollection = FirebaseFirestore.instance.collection(
      Constants().USERS_COLLECTION,
    );

    // 1. Foydalanuvchi ma'lumotlarini olish
    final userDoc = await usersCollection.doc(userId).get();
    final receiverDoc = await usersCollection.doc(receiverId).get();

    if (userDoc.exists && receiverDoc.exists) {
      List<dynamic> lastMessages =
          userDoc.data()?[Constants().LAST_MESSAGE_AND_TIME] ?? [];
      List<dynamic> receiverLastMessages =
          receiverDoc.data()?[Constants().LAST_MESSAGE_AND_TIME] ?? [];

      bool messageExists = false;

      // 2. Xabarni tekshirish va yangilash
      for (var message in lastMessages) {
        if (message[Constants().SENDER_ID] == userId &&
            message[Constants().RECEIVER_ID] == receiverId) {
          // Agar xabar mavjud bo'lsa, yangilash
          message[Constants().MESSAGE] = lastMessage;
          message[Constants().TIMESTAMP] = timestamp;
          messageExists = true;
          break; // Birinchi mos kelganini topganimizdan keyin to'xtatamiz
        }
      }

      // 3. Qabul qiluvchi foydalanuvchini tekshirish
      for (var message in receiverLastMessages) {
        if (message[Constants().SENDER_ID] == receiverId &&
            message[Constants().RECEIVER_ID] == userId) {
          // Agar xabar mavjud bo'lsa, yangilash
          message[Constants().MESSAGE] = lastMessage;
          message[Constants().TIMESTAMP] = timestamp;
          messageExists = true;
          break; // Birinchi mos kelganini topganimizdan keyin to'xtatamiz
        }
      }

      // 4. Agar xabar topilmagan bo'lsa, yangisini qo'shish
      if (!messageExists) {
        lastMessages.add({
          Constants().SENDER_ID: userId,
          Constants().RECEIVER_ID: receiverId,
          Constants().MESSAGE: lastMessage,
          Constants().TIMESTAMP: timestamp,
        });
        receiverLastMessages.add({
          Constants().SENDER_ID: userId,
          Constants().RECEIVER_ID: receiverId,
          Constants().MESSAGE: lastMessage,
          Constants().TIMESTAMP: timestamp,
        });
      }

      // 5. Ikkala foydalanuvchining ma'lumotlarini yangilash
      await usersCollection.doc(userId).update({
        Constants().LAST_MESSAGE_AND_TIME: lastMessages,
      });

      await usersCollection.doc(receiverId).update({
        Constants().LAST_MESSAGE_AND_TIME: receiverLastMessages,
      });
    }
  }

  //get user data
  Future<DocumentSnapshot> getUserData(String userID) {
    return _firestore
        .collection(Constants().USERS_COLLECTION)
        .doc(userID)
        .get();
  }

  Future<List<Post>> getUserPosts(String userID) async {
    List<Post> userPosts = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(Constants().POSTS_COLLECTION)
              .where('userID', isEqualTo: userID)
              .get();

      for (var doc in snapshot.docs) {
        userPosts.add(Post.fromMap(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print("Xatolik" + e.toString());
    }
    return userPosts;
  }

  Future<List<Post>> getAllPosts(String collection) async {
    List<Post> posts = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection(collection)
              .get();

      for (var doc in snapshot.docs) {
        posts.add(Post.fromMap(doc.data() as Map<String, dynamic>));
      }
    } catch (e) {
      print("Xatolik" + e.toString());
    }
    return posts;
  }

  //get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection(Constants().USERS_COLLECTION).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        //go through each individual user
        final user = doc.data();

        //return user
        return user;
      }).toList();
    });
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    //construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection(Constants().DB_CHAT_ROOMS)
        .doc(chatRoomID)
        .collection(Constants().DB_MESSAGES)
        .orderBy(Constants().TIMESTAMP, descending: false)
        .snapshots();
  }
}
