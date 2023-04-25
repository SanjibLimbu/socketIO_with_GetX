import 'dart:io';

import 'package:chat_app/controller/chat_controller.dart';
import 'package:chat_app/modal/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

Color purple = const Color(0xff6c5ce7);
Color black = const Color(0xff191919);

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController msgInputController = TextEditingController();

  late IO.Socket socket;
  ChatController chatController = ChatController();

  @override
  void initState() {
    socket = IO.io(
      'http://localhost:4000',
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter or Dart VM
          .disableAutoConnect() // disable auto-connection
          .build(),
    );
    socket.connect();
    setUpSocketListener();
    super.initState();
  }

  void sendMessage(String text) {
    var messageJson = {
      'message': text,
      'sentByMe': socket.id,
    };
    socket.emit(
      'message',
      messageJson,
    );
    chatController.chatMessages.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      chatController.chatMessages.add(Message.fromJson(data));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: Obx(
              () => ListView.builder(
                  itemCount: chatController.chatMessages.length,
                  itemBuilder: (context, index) {
                    var currentItem = chatController.chatMessages[index];
                    return MessageItem(
                      sendByME: currentItem.sentByMe == socket.id,
                      message: currentItem.message,
                    );
                  }),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: TextField(
              cursorColor: purple,
              style: const TextStyle(
                color: Colors.white,
              ),
              controller: msgInputController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(10),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: Container(
                  decoration: BoxDecoration(
                    color: purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () {
                      sendMessage(msgInputController.text);
                      msgInputController.clear();
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({Key? key, required this.sendByME, required this.message})
      : super(key: key);

  final bool sendByME;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sendByME ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(
          color: sendByME ? purple : Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style: TextStyle(
                color: sendByME ? Colors.white : purple,
                fontSize: 18,
              ),
            ),
            Text(
              '1:00 AM',
              style: TextStyle(
                color: (sendByME ? Colors.white : purple).withOpacity(0.7),
                fontSize: 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
