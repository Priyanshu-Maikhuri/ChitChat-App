import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:chitchat/widgets/chat_messages.dart';
import 'package:chitchat/widgets/new_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    // final token = await messaging.getToken();
    messaging.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ChitChat'),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => FirebaseAuth.instance.signOut())
          ],
        ),
        body: const Column(
          children: [
            Expanded(child: ChatMessages()),
            NewMessages(),
          ],
        ));
  }
}
