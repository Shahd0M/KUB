// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/chat_popup.dart';

class ProviderChatWithUserScreen extends StatefulWidget {
  final String userId;

  const ProviderChatWithUserScreen({super.key, required this.userId});

  @override
  ProviderChatWithUserScreenState createState() => ProviderChatWithUserScreenState();
}

class ProviderChatWithUserScreenState extends State<ProviderChatWithUserScreen> {
  late Stream<DocumentSnapshot> userStream;
  late Stream<QuerySnapshot> chatsStream;
  TextEditingController messageController = TextEditingController();
  bool isTyping = false;
  final ScrollController scrollController = ScrollController();
  FocusNode textFieldFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    userStream = FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots();
    chatsStream = FirebaseFirestore.instance.collection('chats').where('users', arrayContainsAny: [FirebaseAuth.instance.currentUser!.uid, widget.userId]).snapshots();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container();
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('Provider not found');
            } else {
              var userData = snapshot.data!.data() as Map<String, dynamic>;
              var userUsername = userData['username'];
              return Text(userUsername);
            }
          },
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F9F9),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Text('Provider not found');
          } else {
            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10, right: 10, top: 20),
                      child: Column(
                        children: [
                          
                          const SizedBox(height: 14),
                          const SizedBox(height: 4),
                          // Moved buildMessagesList here
                          buildMessagesList(), // Show the messages list
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                buildChatInputField(), // Show the chat input field
              ],
            );
          }
        },
      ),
    );
  }

  Future<String> getUserImageUrl(String userId) async {
    try {
      // Query the Firestore collection 'providers' for the specific provider document
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      // Check if the document exists and contains the 'LogoURL' field
      if (userSnapshot.exists && userSnapshot.data() != null) {
        var userData = userSnapshot.data() as Map<String, dynamic>;
        // Access the 'LogoURL' field and return its value
        return userData['imageURL'] ?? ''; // Return the LogoURL or an empty string if not found
      } else {
        // Provider document not found or LogoURL field is missing, return an empty string
        return '';
      }
    } catch (error) {
      // Error handling
      print('Error fetching provider image URL: $error');
      return ''; // Return an empty string in case of error
    }
  }

  Widget buildMessagesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: chatsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return const Text('Error');
        } else {
          var chats = snapshot.data!.docs;

          return ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var chat = chats[index].data() as Map<String, dynamic>;
              // Check if the chat involves the current user and the selected provider
              if (chat['users'].contains(FirebaseAuth.instance.currentUser!.uid) && chat['users'].contains(widget.userId)) {
                var messagesStream = FirebaseFirestore.instance.collection('chats').doc(chats[index].id).collection('messages').orderBy('timestamp', descending: false).snapshots();
                return StreamBuilder<QuerySnapshot>(
                  stream: messagesStream,
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else if (messageSnapshot.hasError) {
                      return const Text('Error');
                    } else {
                      var messages = messageSnapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var message = messages[index].data() as Map<String, dynamic>;
                          var messageType = message['senderId'] == FirebaseAuth.instance.currentUser!.uid ? ChatMessageType.sender : ChatMessageType.receiver;
                          var text = message['content'];
                          var photoUrlFuture = getUserImageUrl(widget.userId); // Call getProviderImageUrl to get the provider's image URL
                          return FutureBuilder<String>(
                            future: photoUrlFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container();
                              } else if (snapshot.hasError) {
                                return const Text('Error');
                              } else {
                                var photoUrl = snapshot.data; // Get the photo URL from the snapshot
                                return ChatPopup(text: text, messageType: messageType, photoUrl: photoUrl);
                              }
                            },
                          );
                        },
                      );
                    }
                  },
                );
              } else {
                // If the chat does not involve the current user and the selected provider, return an empty container
                return Container();
              }
            },
          );
        }
      },
    );
  }

  Widget buildChatInputField() {
    return Container(
      height: 65,
      margin: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(35),
        child: Container(
          padding: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(35),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 201, 65),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: IconButton(
                  //camera
                  onPressed: () {},
                  icon: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocusNode, // Attach the focus node here
                  maxLines: null,
                  controller: messageController,
                  onChanged: (text) {
                    setState(() {
                      // Set the isTyping flag based on whether the text is empty
                      isTyping = text.isNotEmpty;
                    });
                  },
                  onTap: () {
                    setState(() {
                      // Set the isTyping flag to true when the text field is tapped
                      isTyping = true;
                    });
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Message...",
                    hintStyle: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
              ),
              // Show the send icon if isTyping is true, otherwise show the mic and gallery icons
              isTyping
                  ? IconButton(
                      // Send icon
                      onPressed: () {
                        // Handle sending the message
                        sendMessage(FirebaseAuth.instance.currentUser!.uid, widget.userId);
                        print("Send message: ${messageController.text}");
                        // Clear the text field after sending
                        messageController.clear();
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                    )
                  : Row(
                      children: [
                        IconButton(
                          //mic
                          onPressed: () {},
                          icon: const Icon(
                            Icons.mic,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          //gallery
                          onPressed: () {},
                          icon: const Icon(
                            Icons.photo,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void sendMessage(String senderId, String receiverId) async {
    try {
      // Get the current timestamp
      Timestamp timestamp = Timestamp.now();

      // Get the message content from the text field
      String messageContent = messageController.text;

      // Check if there's an existing chat document between the users
      QuerySnapshot<Map<String, dynamic>> chatQuerySnapshot = await FirebaseFirestore.instance.collection('chats').where('users', whereIn: [
        [senderId, receiverId],
        [receiverId, senderId]
      ]).get();

      if (chatQuerySnapshot.docs.isNotEmpty) {
        // If chat document exists, get the first document found
        DocumentSnapshot<Map<String, dynamic>> chatDocSnapshot = chatQuerySnapshot.docs.first;

        // Add the message to the 'messages' subcollection of the existing chat document
        await FirebaseFirestore.instance.collection('chats').doc(chatDocSnapshot.id).collection('messages').add({
          'senderId': senderId,
          'receiverId': receiverId,
          'timestamp': timestamp,
          'content': messageContent,
        });
      } else {
        // If no chat document exists, create a new one
        DocumentReference chatDocRef = await FirebaseFirestore.instance.collection('chats').add({
          'users': [senderId, receiverId],
        });

        // Add the message to the 'messages' subcollection of the newly created chat document
        await chatDocRef.collection('messages').add({
          'senderId': senderId,
          'receiverId': receiverId,
          'timestamp': timestamp,
          'content': messageContent,
        });
      }

      // Message sent successfully
      print('Message sent successfully');
    } catch (error) {
      // Error handling
      print('Failed to send message: $error');
    }
  }
}
