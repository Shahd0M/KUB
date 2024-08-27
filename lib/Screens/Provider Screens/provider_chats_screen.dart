import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_info_for_chat.dart';
import '../../widgets/provider_nav_bar.dart';
import 'provider_chat_with_user.dart';
import 'provider_home_screen.dart';
import 'provider_orders_screen.dart';
import 'provider_settings.dart';

class ProviderChatsTab extends StatefulWidget {
  final int navBarIndex;

  const ProviderChatsTab({super.key, required this.navBarIndex});

  @override
  State<ProviderChatsTab> createState() => ProviderChatsTabState();
}

class ProviderChatsTabState extends State<ProviderChatsTab> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.navBarIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Chats"),
      ),
      bottomNavigationBar: ProviderBottomNavigationBarWrapper(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          // Handle navigation based on the index
          switch (index) {
            case 0:
            // Navigate to Home screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const ProviderHomeScreen(navBarIndex: 0)));
              //Navigator.pushReplacementNamed(context, '/userHome');
              break;
            case 1:
            // Navigate to Profile screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const ProviderChatsTab(navBarIndex: 1)));
              //Navigator.pushReplacementNamed(context, '/userProfile');
              break;
            case 2:
            // Navigate to Favorites screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const ProviderSettingsTab(navBarIndex: 2)));
              //Navigator.pushReplacementNamed(context, '/userFavorites');
              break;
            case 3:
            // Navigate to Cart screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const ProviderOrdersTab(navBarIndex: 3)));
              //Navigator.pushReplacementNamed(context, '/userCart');
              break;
          }
        },
      ),
      body: const ProviderChatsTabContent(), // Replace with your actual content
    );
  }
}

class ProviderChatsTabContent extends StatefulWidget {
  const ProviderChatsTabContent({super.key});

  @override
  State<ProviderChatsTabContent> createState() =>
      _ProviderChatsTabContentState();
}

class _ProviderChatsTabContentState extends State<ProviderChatsTabContent> {
  //late TextEditingController _searchController;
  late Stream<List<DocumentSnapshot>> _chatsStream;
  late Future<List<UserInfoForChat>> usersInfo;
  late String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    //_searchController = TextEditingController();
    _chatsStream = getChatsStream();
    _refreshData();
  }

  // Method to refresh the data
  Future<void> _refreshData() async {
    setState(() {
      _chatsStream = getChatsStream();
    });
  }




  // Stream<List<DocumentSnapshot>> getChatsStream() {
  //   final currentUserID = FirebaseAuth.instance.currentUser!.uid;
  //   return FirebaseFirestore.instance
  //       .collection('chats')
  //       .where('users', arrayContains: currentUserID)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs);
  // }

  Stream<List<DocumentSnapshot<Object?>>> getChatsStream() {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserID)
        .snapshots()
        .asyncMap((snapshot) async {
      final chats = snapshot.docs;
      // Fetch the last message timestamp for each chat
      final List<Future<Map<String, dynamic>>> lastMessageTimes = chats.map((chatDoc) async {
        final messagesQuerySnapshot = await chatDoc.reference.collection('messages').orderBy('timestamp', descending: true).limit(1).get();
        if (messagesQuerySnapshot.docs.isNotEmpty) {
          final lastMessageDoc = messagesQuerySnapshot.docs.first;
          return {
            'chatID': chatDoc.id,
            'timestamp': (lastMessageDoc['timestamp'] as Timestamp).toDate(),
          };
        } else {
          return {
            'chatID': chatDoc.id,
            'timestamp': null,
          };
        }
      }).toList();
      // Wait for all last message timestamp queries to complete
      final List<Map<String, dynamic>> messageTimes = await Future.wait(lastMessageTimes);
      // Sort the chats based on the last message timestamp
      messageTimes.sort((a, b) {
        final aTimestamp = a['timestamp'] as DateTime?;
        final bTimestamp = b['timestamp'] as DateTime?;
        if (aTimestamp == null && bTimestamp == null) {
          return 0;
        } else if (aTimestamp == null) {
          return 1;
        } else if (bTimestamp == null) {
          return -1;
        } else {
          return bTimestamp.compareTo(aTimestamp);
        }
      });
      // Fetch the chat documents using the chat IDs
      final List<DocumentSnapshot<Object?>> chatDocuments = await Future.wait(messageTimes.map((data) => FirebaseFirestore.instance.collection('chats').doc(data['chatID']).get()));
      // Return the sorted chat documents
      return chatDocuments;
    });
  }

  // Stream<List<DocumentSnapshot>> getChatsStream() {
  //   final currentUserID = FirebaseAuth.instance.currentUser!.uid;
  //   return FirebaseFirestore.instance.collection('chats').where('users', arrayContains: currentUserID)
  //       .orderBy('latestMessage.timestamp', descending: true) // Order chats by the timestamp of the latest message
  //       .snapshots().map((snapshot) => snapshot.docs);
  // }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _chatsStream = getChatsStream();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _chatsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final chats = snapshot.data!;
                    if (chats.isEmpty) {
                      return const Center(
                          child: Text("You don't have any chats yet"));
                    } else {
                      usersInfo = getUsersInfo(chats);

                      return FutureBuilder<List<UserInfoForChat>>(
                        future: usersInfo,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final usersInfoList = snapshot.data!;
                            if (usersInfoList.isEmpty) {
                              // usersInfoList is empty
                              // Handle the case where no user information is available
                              print('User information is empty');
                            } else {
                              // usersInfoList is not empty
                              // Proceed with using the user information
                              print('User information is not empty');
                            }
                            final filteredUsers = _filterUsers(usersInfoList);
                            print(filteredUsers);
                            return ListView.builder(
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final userInfo = filteredUsers[index];
                                return ListTile(
                                  title: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset(
                                          userInfo.imagePath,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                userInfo.name,
                                                style: const TextStyle(
                                                    fontSize: 22),
                                              ),
                                              const SizedBox(width: 25),
                                              FutureBuilder<DateTime?>(
                                                future: getLastMessageTime(
                                                    userInfo.uid),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                      .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Container();
                                                  } else if (snapshot
                                                      .hasError) {
                                                    return Text(
                                                        'Error: ${snapshot.error}');
                                                  } else {
                                                    final lastMessageTime =
                                                        snapshot.data;
                                                    final formattedTime =
                                                    lastMessageTime != null
                                                        ? formatMessageTime(
                                                        lastMessageTime)
                                                        : 'No messages';
                                                    return Text(
                                                      formattedTime,
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Color.fromARGB(
                                                              255,
                                                              131,
                                                              130,
                                                              130)),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          FutureBuilder<String?>(
                                            future:
                                            getLastMessage(userInfo.uid),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Container();
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}');
                                              } else {
                                                final lastMessage =
                                                    snapshot.data;
                                                final truncatedMessage =
                                                lastMessage != null &&
                                                    lastMessage.length >
                                                        30
                                                    ? '${lastMessage.substring(0, 30)}...' // Truncate the message if it's longer than 30 characters
                                                    : lastMessage;
                                                return Text(
                                                  truncatedMessage ??
                                                      'No messages',
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      color: Color.fromARGB(
                                                          255, 131, 130, 130)),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProviderChatWithUserScreen(
                                                    userId: userInfo.uid)));
                                  },
                                );
                              },
                            );
                          }
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<UserInfoForChat> _filterUsers(List<UserInfoForChat> users) {
    if (_searchQuery.isEmpty) {
      return users;
    } else {
      return users
          .where((user) =>
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  Future<List<UserInfoForChat>> getUsersInfo(
      List<DocumentSnapshot> chats) async {
    final usersInfo = <UserInfoForChat>[];
    for (final chat in chats) {
      final List<String> users = List<String>.from(chat['users']);
      users.removeWhere(
              (userId) => userId == FirebaseAuth.instance.currentUser!.uid);
      final userId = users.first;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final username = data['username'] as String?;
        print(username);
        final imageURL = data['imageURL'] as String?;
        print(imageURL);

        if (username != null) {
          usersInfo
              .add(UserInfoForChat(uid: userId, name: username, imagePath: "lib/assets/userImage.jpg"));
        }
      }
    }
    print(usersInfo);
    return usersInfo;
  }

  Future<String?> getLastMessage(String userId) async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final chatDocs = querySnapshot.docs;
      // Filter chats where the other user's ID matches the provided userId
      final relevantChats = chatDocs.where((chatDoc) {
        final users = chatDoc['users'] as List<dynamic>;
        return users.contains(userId);
      }).toList();

      if (relevantChats.isNotEmpty) {
        // Fetch the last message for each relevant chat
        final List<Future<String?>> lastMessages =
        relevantChats.map((chatDoc) async {
          final messagesQuerySnapshot = await chatDoc.reference
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();
          if (messagesQuerySnapshot.docs.isNotEmpty) {
            final lastMessageDoc = messagesQuerySnapshot.docs.first;
            return lastMessageDoc['content'] as String?;
          } else {
            return null;
          }
        }).toList();
        // Wait for all last message queries to complete
        final List<String?> messages = await Future.wait(lastMessages);
        // Return the last message from the list of messages
        return messages.isNotEmpty ? messages.first : null;
      }
    }
    return null;
  }

  Future<DateTime?> getLastMessageTime(String providerId) async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserID)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final chatDocs = querySnapshot.docs;
      // Filter chats where the other user's ID matches the provided providerId
      final relevantChats = chatDocs.where((chatDoc) {
        final users = chatDoc['users'] as List<dynamic>;
        return users.contains(providerId);
      }).toList();

      if (relevantChats.isNotEmpty) {
        // Fetch the timestamp of the last message for each relevant chat
        final List<Future<DateTime?>> lastMessageTimes =
        relevantChats.map((chatDoc) async {
          final messagesQuerySnapshot = await chatDoc.reference
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();
          if (messagesQuerySnapshot.docs.isNotEmpty) {
            final lastMessageDoc = messagesQuerySnapshot.docs.first;
            return (lastMessageDoc['timestamp'] as Timestamp).toDate();
          } else {
            return null;
          }
        }).toList();
        // Wait for all last message timestamp queries to complete
        final List<DateTime?> messageTimes =
        await Future.wait(lastMessageTimes);
        // Return the latest message timestamp
        return messageTimes.isNotEmpty ? messageTimes.first : null;
      }
    }
    return null;
  }

  String formatMessageTime(DateTime? messageTime) {
    if (messageTime == null) {
      return 'No messages';
    }

    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}m';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y';
    }
  }
}
