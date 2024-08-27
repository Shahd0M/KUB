import 'package:authentication/Screens/User%20Screens/user_cart.dart';
import 'package:authentication/Screens/User%20Screens/user_home_screen.dart';
import 'package:authentication/Screens/User%20Screens/user_profile.dart';
import 'package:authentication/widgets/brand_posts.dart';
import 'package:authentication/widgets/custom_expansion_tile.dart';
import 'package:authentication/widgets/user_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserFavouritesTab extends StatefulWidget {
  final int navBarIndex;

  const UserFavouritesTab({super.key, required this.navBarIndex});

  @override
  State<UserFavouritesTab> createState() => UserFavouritesTabState();
}

class UserFavouritesTabState extends State<UserFavouritesTab> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.navBarIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserHomeScreen(navBarIndex: 0)));
              break;
            case 1:
            // Navigate to Profile screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserProfileTab(navBarIndex: 1)));
              break;
            case 2:
            // Navigate to Favorites screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserFavouritesTab(navBarIndex: 2)));
              break;
            case 3:
            // Navigate to Cart screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CartScreen(navBarIndex: 3)));
              break;
          }
        },
      ),
      body: const YourAllCategoriesScreenContent(), // Replace with your actual content
    );
  }
}

class YourAllCategoriesScreenContent extends StatefulWidget {
  const YourAllCategoriesScreenContent({Key? key}) : super(key: key);

  @override
  State<YourAllCategoriesScreenContent> createState() => YourAllCategoriesScreenContentState();
}

class YourAllCategoriesScreenContentState extends State<YourAllCategoriesScreenContent> {
  late Stream<DocumentSnapshot> _userDataStream;
  late List<DocumentSnapshot<Map<String, dynamic>>> _postSnapshots = [];

  Stream<DocumentSnapshot> _getUserDataStream() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  Future<void> _fetchPosts(List<dynamic> userFavs) async {
    _postSnapshots.clear();

    for (var fav in userFavs) {
      String pageID = fav['pageID'] ?? ''; // Check for null and provide a default value
      String postID = fav['postID'] ?? ''; // Check for null and provide a default value

      if (pageID.isNotEmpty && postID.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> postSnapshot = await FirebaseFirestore.instance
            .collection('providers')
            .doc(pageID)
            .collection('posts')
            .doc(postID)
            .get();

        if (postSnapshot.exists) {
          _postSnapshots.add(postSnapshot);
        }
      }
    }

    setState(() {});
  }

  Future<String> _getPageName(String pageID) async {

    DocumentSnapshot<Map<String, dynamic>> pageSnapshot = await FirebaseFirestore.instance
        .collection('providers')
        .doc(pageID)
        .get();

    if (pageSnapshot.exists) {
      var data = pageSnapshot.data();
      print('Page data for $pageID: $data');
      if (data != null && data.containsKey('username')) {
        return data['username'] ?? 'Unknown';
      } else {
        return 'Revolution'; // Return a default value if 'username' is not found
      }
    } else {
      print('Page document does not exist for $pageID');
      return 'Revolution'; // Return a default value if page is not found
    }
  }



  Future<Map<String, List<DocumentSnapshot>>> _groupPostsByPageID() async {
    Map<String, List<DocumentSnapshot>> pageGroups = {};

    for (var postSnapshot in _postSnapshots) {
      var postData = postSnapshot.data();
      if (postData != null) {
        var pageID = postData['pageID'] ?? 'unknown'; // Check for null and provide a default value
        if (!pageGroups.containsKey(pageID)) {
          pageGroups[pageID] = [];
        }
        pageGroups[pageID]!.add(postSnapshot);
      }
    }

    return pageGroups;
  }

  @override
  void initState() {
    super.initState();
    _userDataStream = _getUserDataStream();

    _userDataStream.listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic>? _userData = snapshot.data() as Map<String, dynamic>?;
        if (_userData != null) {
          List<dynamic>? userFavs = _userData['favs'];
          if (userFavs != null) {
            _fetchPosts(userFavs);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "Favourite",
                  style: TextStyle(fontSize: 24),
                ),
                centerTitle: true,
              ),
              body: Padding(
                padding: const EdgeInsets.all(12),
                child: FutureBuilder<Map<String, List<DocumentSnapshot>>>(
                  future: _groupPostsByPageID(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      var pageGroups = snapshot.data!;
                      if (pageGroups.isEmpty) {
                        return Center(child: Text('No favorite posts found'));
                      } else {
                        return ListView.builder(
                          itemCount: pageGroups.length,
                          itemBuilder: (context, index) {
                            var pageID = pageGroups.keys.toList()[index];
                            var postSnapshots = pageGroups[pageID]!;
                            return FutureBuilder<String>(
                              future: _getPageName(pageID),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return ListTile(
                                    title: Text('Error: ${snapshot.error}'),
                                  );
                                } else {
                                  return CustomExpansionTile(
                                    title: snapshot.data!,
                                    children: [
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                          childAspectRatio: 1,
                                        ),
                                        itemCount: postSnapshots.length,
                                        itemBuilder: (context, index) {
                                          var postSnapshot = postSnapshots[index];
                                          var postData = postSnapshot.data() as Map<String, dynamic>;
                                          return BrandPosts(
                                            postData,
                                            FirebaseAuth.instance.currentUser!.uid,
                                            postSnapshot.id,
                                            pageID,
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            );
          } else {
            return Center(child: Text('No data found'));
          }
        }
      },
    );
  }
}
