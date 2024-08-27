import 'package:authentication/Screens/User%20Screens/user_order_details.dart';
import 'package:authentication/Screens/User%20Screens/user_favourites.dart';
import 'package:authentication/Screens/User%20Screens/user_home_screen.dart';
import 'package:authentication/Screens/User%20Screens/user_profile.dart';
import 'package:authentication/main.dart';
import 'package:authentication/widgets/custom_expansion_tile.dart';
import 'package:authentication/widgets/user_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/user_cart_widget.dart';

class CartScreen extends StatefulWidget {
  final int navBarIndex;

  const CartScreen({super.key,required this.navBarIndex});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
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
              //Navigator.pushReplacementNamed(context, '/userHome');
              break;
            case 1:
            // Navigate to Profile screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserProfileTab(navBarIndex: 1)));
              //Navigator.pushReplacementNamed(context, '/userProfile');
              break;
            case 2:
            // Navigate to Favorites screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserFavouritesTab(navBarIndex: 2)));
              //Navigator.pushReplacementNamed(context, '/userFavorites');
              break;
            case 3:
            // Navigate to Cart screen
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CartScreen(navBarIndex: 3)));
              //Navigator.pushReplacementNamed(context, '/userCart');
              break;
          }
        },
      ),
      body: const CartScreenContent(), // Replace with your actual content
    );
  }
}

class CartScreenContent extends StatefulWidget {
  // final int navBarIndex;

  const CartScreenContent({Key? key,}) : super(key: key);

  @override
  State<CartScreenContent> createState() => CartScreenContentState();
}

class CartScreenContentState extends State<CartScreenContent> {
  late Stream<DocumentSnapshot> _userDataStream;
  late List<String> _pageIDs = [];
  late Map<String, List<DocumentSnapshot<Map<String, dynamic>>>> _postsByPage = {};

  late List<Map<String, dynamic>> _allWhatWeGonnaBuy = []; // List to store all items to buy

  // String? selectedColor ;
  // String? selectedSize;
  // int? quantity;


  Stream<DocumentSnapshot> _getUserDataStream() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  Future<void> _fetchPosts(List<dynamic> userCart) async {
    _pageIDs.clear();
    _postsByPage.clear();

    for (var item in userCart) {
      String pageID = item['pageID'];
      String postID = item['postID'];

      DocumentSnapshot<Map<String, dynamic>> cartSnapshot = await FirebaseFirestore.instance
          .collection('providers')
          .doc(pageID)
          .collection('posts')
          .doc(postID)
          .get();

      // Group posts by page ID
      if (!_pageIDs.contains(pageID)) {
        _pageIDs.add(pageID);
        _postsByPage[pageID] = [cartSnapshot];
      } else {
        _postsByPage[pageID]?.add(cartSnapshot);
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
      return pageSnapshot.data()!['username'];
    } else {
      return 'Unknown'; // Return a default value if page is not found
    }
  }

  @override
  void initState() {
    super.initState();
    _userDataStream = _getUserDataStream();

    _userDataStream.listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> _userData = snapshot.data() as Map<String, dynamic>;
        List<dynamic>? userCart = _userData['cart'];
        if (userCart != null) {
          _fetchPosts(userCart);
        }
      }
    });
  }

  int _expandedTileIndex = -1; // Track the index of the currently expanded tile

  void _handleExpansion(int index) {
    // Clear _allWhatWeGonnaBuy
      _allWhatWeGonnaBuy.clear();
      _expandedTileIndex = index; // Set the index of the currently expanded tile

  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "Cart",
                  style: TextStyle(fontSize: 24),
                ),
                centerTitle: true,
              ),
              body: ListView.builder(
                itemCount: _pageIDs.length,
                itemBuilder: (context, index) {
                  print("LIST VIEW 1: ${_pageIDs.length}");

                  String pageID = _pageIDs[index];
                  List<DocumentSnapshot<Map<String, dynamic>>> posts = _postsByPage[pageID] ?? [];

                  return FutureBuilder<String>(
                    future: _getPageName(pageID),
                    builder: (context, snapshot) {
                      print("LIST VIEW 2: ${_pageIDs.length}");
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return ListTile(
                          title: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return CustomExpansionTile(
                          title: snapshot.data!,

                          initiallyExpanded: index == _expandedTileIndex,
                          onExpansionChanged: (expanded) {
                            if (expanded) {
                              // If the tile is expanded, clear _allWhatWeGonnaBuy
                              _handleExpansion(index);
                            } else {
                              // If the tile is collapsed, reset the expanded tile index
                                _expandedTileIndex = -1;
                            }
                          },

                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              itemBuilder: (context, index) {
                                var postSnapshot = posts[index];
                                var postData = postSnapshot.data()!;

                                // This has the data for all posts by same page
                                print('posts $postData');

                                return CartItemWidget(
                                  postDetails: postData,
                                  userID: FirebaseAuth.instance.currentUser!.uid,
                                  postID: postSnapshot.id,
                                  pageID: pageID,

                                  onItemDetailsChanged: (itemDetails) {
                                    // Check if the item already exists in the list
                                    int existingIndex = _allWhatWeGonnaBuy.indexWhere((item) => item['postID'] == itemDetails['postID']);

                                    if (existingIndex != -1) {
                                      // If item exists, update only the specific fields that change

                                        // Update color if it's not null
                                        if (itemDetails['selectedColor'] != null) {
                                          _allWhatWeGonnaBuy[existingIndex]['selectedColor'] = itemDetails['selectedColor'];
                                        }

                                        // Update size if it's not null
                                        if (itemDetails['selectedSize'] != null) {
                                          _allWhatWeGonnaBuy[existingIndex]['selectedSize'] = itemDetails['selectedSize'];
                                        }

                                        // Update quantity
                                        _allWhatWeGonnaBuy[existingIndex]['quantity'] = itemDetails['quantity'];

                                    } else {
                                      // If item doesn't exist, add it to the list
                                        _allWhatWeGonnaBuy.add(itemDetails);

                                    }
                                    print('allWhatWeGonnaBuy ::: $_allWhatWeGonnaBuy');
                                  },

                                );
                              },
                            ),

                            GestureDetector(
                              onTap: () {
                                if (_allWhatWeGonnaBuy.isNotEmpty) {
                                  // Check if selectedColor and selectedSize are not null for all items
                                  bool allItemsHaveColorAndSize = _allWhatWeGonnaBuy.every((item) {
                                    return item['selectedColor'] != null && item['selectedSize'] != null;
                                  });

                                  if (allItemsHaveColorAndSize) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderDetailsPage(allWhatWeGonnaBuy: _allWhatWeGonnaBuy),
                                      ),
                                    );
                                  } else {
                                    showToast(message: 'Please select color and size for all items');
                                  }
                                } else {
                                  showToast(message: 'No items to order');
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 198, 50, 1.0),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart,
                                      color:Color(0xFF0D0A35),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Place Order',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF0D0A35),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          // initiallyExpanded: true,
                        );
                      }
                    },
                  );
                },
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