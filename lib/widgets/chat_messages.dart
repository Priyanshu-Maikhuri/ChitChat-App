import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:chitchat/widgets/message_bubble.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final authenticatedUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No new messages currently...'),
            );
          }

          if (chatSnapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final messages = chatSnapshot.data!.docs;

          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final chatMessage = messages[index].data();
              final nextChatMessage = index + 1 < messages.length
                  ? messages[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              if (currentMessageUserId == nextMessageUserId) {
                return MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: currentMessageUserId == authenticatedUser.uid);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['userName'],
                    message: chatMessage['text'],
                    isMe: currentMessageUserId == authenticatedUser.uid);
              }
            },
          );
        });
  }
}
