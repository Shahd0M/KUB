import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/user_info_for_chat.dart';
import '../../widgets/user_nav_bar.dart';
import 'user_chat_with_provider.dart';

class UserMainChatScreen extends StatefulWidget {
  const UserMainChatScreen({super.key});

  @override
  State<UserMainChatScreen> createState() => _UserMainChatScreenState();
}

class _UserMainChatScreenState extends State<UserMainChatScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        centerTitle: true,
      ),
      bottomNavigationBar: UserBottomNavigationBarWrapper(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          // Handle navigation based on the index
          switch (index) {
            case 0:
              // Navigate to Home screen
              Navigator.pushReplacementNamed(context, '/userHome');
              break;
            case 1:
              // Navigate to Profile screen
              Navigator.pushReplacementNamed(context, '/userProfile');
              break;
            case 2:
              // Navigate to Favorites screen
              Navigator.pushReplacementNamed(context, '/userFavorites');
              break;
            case 3:
              // Navigate to Cart screen
              Navigator.pushReplacementNamed(context, '/userCart');
              break;
          }
        },
      ),
      body: const UserMainChatScreenContent(), // R
    );
  }
}

class UserMainChatScreenContent extends StatefulWidget {
  const UserMainChatScreenContent({super.key});

  @override
  UserMainChatScreenContentState createState() => UserMainChatScreenContentState();
}

class UserMainChatScreenContentState extends State<UserMainChatScreenContent> {
  late Stream<List<DocumentSnapshot>> _chatsStream;
  late List<String> providerIdsChatsList = [];
  late Future<List<UserInfoForChat>> providersInfo;
  late String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _chatsStream = getChatsStream();
  }


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
            Container(
              margin: const EdgeInsets.only(left: 15, right: 15),
              height: 60,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: _chatsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var chats = snapshot.data!;
                    if (chats.isEmpty) {
                      return const Center(child: Text("You don't have any chats yet"));
                    } else {
                      // chats = chats.reversed.toList();

                      providersInfo = getProvidersInfo(chats);
                      return FutureBuilder<List<UserInfoForChat>>(
                        future: providersInfo,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final providersInfo = snapshot.data!;
                            final filteredProviders = _filterProviders(providersInfo);
                            return ListView.builder(
                              itemCount: filteredProviders.length,
                              itemBuilder: (context, index) {
                                final providerInfo = filteredProviders[index];
                                return ListTile(
                                  title: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          providerInfo.imagePath,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                providerInfo.name,
                                                style: const TextStyle(fontSize: 22),
                                              ),
                                              const SizedBox(width: 25),
                                              FutureBuilder<DateTime?>(
                                                future: getLastMessageTime(providerInfo.uid),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return Container();
                                                  } else if (snapshot.hasError) {
                                                    return Text('Error: ${snapshot.error}');
                                                  } else {
                                                    final lastMessageTime = snapshot.data;
                                                    final formattedTime = lastMessageTime != null ? formatMessageTime(lastMessageTime) : 'No messages';
                                                    return Text(
                                                      formattedTime,
                                                      style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 131, 130, 130)),
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          FutureBuilder<String?>(
                                            future: getLastMessage(providerInfo.uid),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState == ConnectionState.waiting) {
                                                return Container();
                                              } else if (snapshot.hasError) {
                                                return Text('Error: ${snapshot.error}');
                                              } else {
                                                final lastMessage = snapshot.data;
                                                final truncatedMessage = lastMessage != null && lastMessage.length > 30
                                                    ? '${lastMessage.substring(0, 30)}...' // Truncate the message if it's longer than 30 characters
                                                    : lastMessage;
                                                return Text(
                                                  truncatedMessage ?? 'No messages',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 131, 130, 130)),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => UserChatWithProviderScreen(providerId: providerInfo.uid)));
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

  List<UserInfoForChat> _filterProviders(List<UserInfoForChat> providers) {
    if (_searchQuery.isEmpty) {
      return providers;
    } else {
      return providers.where((provider) => provider.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
  }

  Future<List<UserInfoForChat>> getProvidersInfo(List<DocumentSnapshot> chats) async {
    final providersInfo = <UserInfoForChat>[];
    for (final chat in chats) {
      final List<String> providers = List<String>.from(chat['users']);
      providers.removeWhere((providerId) => providerId == FirebaseAuth.instance.currentUser!.uid);
      final providerId = providers.first;
      final docSnapshot = await FirebaseFirestore.instance.collection('providers').doc(providerId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final username = data['username'] as String?;
        final logoURL = data['LogoURL'] as String?;
        if (username != null && logoURL != null) {
          providersInfo.add(UserInfoForChat(uid: providerId, name: username, imagePath: logoURL));
        }
      }
    }
    return providersInfo;
  }

  Future<String?> getLastMessage(String userId) async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    final querySnapshot = await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: currentUserID).get();

    if (querySnapshot.docs.isNotEmpty) {
      final chatDocs = querySnapshot.docs;
      // Filter chats where the other user's ID matches the provided userId
      final relevantChats = chatDocs.where((chatDoc) {
        final users = chatDoc['users'] as List<dynamic>;
        return users.contains(userId);
      }).toList();

      if (relevantChats.isNotEmpty) {
        // Fetch the last message for each relevant chat
        final List<Future<String?>> lastMessages = relevantChats.map((chatDoc) async {
          final messagesQuerySnapshot = await chatDoc.reference.collection('messages').orderBy('timestamp', descending: true).limit(1).get();
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

    final querySnapshot = await FirebaseFirestore.instance.collection('chats').where('users', arrayContains: currentUserID).get();

    if (querySnapshot.docs.isNotEmpty) {
      final chatDocs = querySnapshot.docs;
      // Filter chats where the other user's ID matches the provided providerId
      final relevantChats = chatDocs.where((chatDoc) {
        final users = chatDoc['users'] as List<dynamic>;
        return users.contains(providerId);
      }).toList();

      if (relevantChats.isNotEmpty) {
        // Fetch the timestamp of the last message for each relevant chat
        final List<Future<DateTime?>> lastMessageTimes = relevantChats.map((chatDoc) async {
          final messagesQuerySnapshot = await chatDoc.reference.collection('messages').orderBy('timestamp', descending: true).limit(1).get();
          if (messagesQuerySnapshot.docs.isNotEmpty) {
            final lastMessageDoc = messagesQuerySnapshot.docs.first;
            return (lastMessageDoc['timestamp'] as Timestamp).toDate();
          } else {
            return null;
          }
        }).toList();
        // Wait for all last message timestamp queries to complete
        final List<DateTime?> messageTimes = await Future.wait(lastMessageTimes);
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
