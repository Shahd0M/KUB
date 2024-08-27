import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final String senderId;
  final Timestamp timestamp;

  ChatMessage({
    required this.text,
    required this.senderId,
    required this.timestamp,
  });
}
