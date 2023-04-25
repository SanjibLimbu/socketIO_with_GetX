import 'package:chat_app/chat_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChatApp());
}


class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Socket IO App',
      home: ChatScreen(),
    );
  }
}
