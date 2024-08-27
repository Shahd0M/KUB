import 'package:flutter/material.dart';

enum ChatMessageType { sender, receiver }

class ChatPopup extends StatelessWidget {
  final String text;
  final ChatMessageType messageType;
  final String? photoUrl; // Optional parameter for the photo URL

  const ChatPopup({super.key, required this.text, required this.messageType, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        mainAxisAlignment: messageType == ChatMessageType.sender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start, // Align text to the top
        children: [
          if (messageType == ChatMessageType.receiver && photoUrl != null) // Display photo only for receiver
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(photoUrl!), // Assuming photoUrl is not null
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: messageType == ChatMessageType.sender ? const Color(0xFF0D0A35) : const Color(0xFFD9D9D9),
                borderRadius: const BorderRadius.all(Radius.circular(30)),
              ),
              child: Text(
                text,
                style: TextStyle(fontSize: 16, color: messageType == ChatMessageType.sender ? Colors.white : Colors.black),
                softWrap: true, // Allow text to wrap to multiple lines
              ),
            ),
          ),
        ],
      ),
    );
  }
}
