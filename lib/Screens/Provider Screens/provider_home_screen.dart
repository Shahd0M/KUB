import 'package:authentication/Screens/Main%20Screens/full_screen_img.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Design/Provider_categories_Design.dart';
import '../../widgets/brand_posts.dart';
import '../../widgets/provider_nav_bar.dart';
import '../../widgets/provider_posts.dart';
import 'provider_add_items.dart';
import 'provider_chats_screen.dart';
import 'provider_orders_screen.dart';
import 'provider_settings.dart';


class ProviderHomeScreen extends StatefulWidget {
  final int navBarIndex;

  const ProviderHomeScreen({required this.navBarIndex});

  @override
  State<ProviderHomeScreen> createState() => ProviderHomeScreenState();
}

class ProviderHomeScreenState extends State<ProviderHomeScreen> {

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.navBarIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ProviderBottomNavigationBarWrapper(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderHomeScreen(navBarIndex: 0)));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderChatsTab(navBarIndex: 1)));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderSettingsTab(navBarIndex: 2)));
              break;
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderOrdersTab(navBarIndex: 3)));
              break;
          }
        },
      ),
      body: const ProviderProfileTabContent(), // Replace with your actual content
    );
  }
}

class ProviderProfileTabContent extends StatefulWidget {
  const ProviderProfileTabContent({Key? key});

  @override
  State<ProviderProfileTabContent> createState() => ProviderProfileTabContentState();
}

class ProviderProfileTabContentState extends State<ProviderProfileTabContent> {
  late Future<DocumentSnapshot> _futureProviderData;
  late Stream<DocumentSnapshot> _providerDataStream;


  //late Stream<DocumentSnapshot> _providerDataPostsStream;

  String userId = FirebaseAuth.instance.currentUser!.uid;
  List<dynamic> _providerCategories = [];
  List<String> _subCategories = [];


  @override
  void initState() {
    super.initState();
    _fetchUserCategories();
    _providerDataStream = _getUserDataStream();
    getPosts();
  }


  List<dynamic> posts = [];

  getPosts() async {
    await FirebaseFirestore.instance
        .collection('providers')
        .doc(userId)
        .collection('posts')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
        postData['id'] = doc.id; // Add document ID to the postData
        posts.add(postData);
      });
    }).catchError((error) {
      print("Error getting posts: $error");
    });
  }


  Stream<DocumentSnapshot> _getUserDataStream() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance.collection('providers').doc(userId).snapshots();
  }



  Future<void> _fetchUserCategories() async {
    try {
      // Get the current user ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the provider document for the current user
      DocumentSnapshot<Map<String, dynamic>> providerSnapshot =
      await FirebaseFirestore.instance.collection('providers').doc(userId).get();

      // Check if the provider document exists and contains the 'categories' field
      if (providerSnapshot.exists && providerSnapshot.data()!.containsKey('categories')) {
        // Access the categories array in the provider document
        List<dynamic> categoriesArray = providerSnapshot.data()!['categories'];
        print('this is categories array : $categoriesArray');
        setState(() {
          _providerCategories = categoriesArray.map((color) => color.toString()).toList();
        });
        print(_providerCategories);

        _fetchCategoriesForProvider(_providerCategories);
      } else {
        print("Provider document does not exist or does not contain 'categories' field");
      }
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching user categories: $e');
    }
  }

  Future<void> _fetchCategoriesForProvider(List<dynamic> providerCategories) async {
    try {
      List<String> subCategories = [];

      // Loop through each category ID in the providerCategories list
      for (var categoryId in providerCategories) {
        // Fetch documents from the 'categories' collection that match the category ID
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('categories')
            .where(FieldPath.documentId, isEqualTo: categoryId)
            .get();

        // Loop through the documents in the snapshot
        snapshot.docs.forEach((doc) {
          // Extract the 'subCategories' field from each document and add it to the subCategories list
          if (doc.data().containsKey('subCategories')) {
            subCategories.addAll(List<String>.from(doc.data()['subCategories']));
          }
        });
      }
      print('subcategories : $subCategories');

      // Save the fetched subcategories in _subCategories list
      setState(() {
        _subCategories = subCategories;
      });
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching categories for provider: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _providerDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            DocumentSnapshot providerDataSnapshot = snapshot.data!;
            Map<String, dynamic> _providerData = providerDataSnapshot.data() as Map<String, dynamic>;
            String? logoURL = _providerData.isNotEmpty ? _providerData['LogoURL'] ?? '' : '';
            String? username = _providerData.isNotEmpty ? _providerData['username'] ?? '' : '';
            List<dynamic>? followers = _providerData.isNotEmpty ? _providerData['followers'] ?? [] : [];

            int postsCount = posts!.length;
            int followersCount = followers!.length;

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImage(imageUrl: logoURL ?? ''),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(logoURL ?? ''),
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username ?? '',
                                style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "${postsCount}",
                                        style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Posts",
                                        style: TextStyle(color: Colors.grey, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 30),
                                  Column(
                                    children: [
                                      Text(
                                        "${followersCount}",
                                        style: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Followers",
                                        style: TextStyle(color: Colors.grey, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AddItem()));
                          },
                          child: Container(
                            width: 200,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), // Reduced horizontal padding for better alignment
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 13, 10, 83),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.white), // Plus icon
                                SizedBox(width: 8), // SizedBox for spacing between icon and text
                                Text(
                                  'Add Item',
                                  style: TextStyle(color: Colors.white, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      "Categories",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      margin: const EdgeInsets.all(10),
                      height: MediaQuery.of(context).size.height * 0.13,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _subCategories.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3, // Adjust the width as needed
                            child: ProviderCategoriesDesign(
                              image: AssetImage('lib/assets/profile_brand/categories_basic_image_.jpg'),
                              onTap: () {
                                // Handle onTap action
                              },
                              title: _subCategories[index], // Use list item as title
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Posts",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: GridView.builder(
                        shrinkWrap: true, // Add this to prevent the GridView from occupying infinite height
                        physics: NeverScrollableScrollPhysics(), // Add this to prevent the GridView from scrolling
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns in the grid
                          crossAxisSpacing: 10, // Spacing between columns
                          mainAxisSpacing: 10, // Spacing between rows
                          childAspectRatio: 1, // Aspect ratio of each grid item (width / height)
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return ProviderPosts(posts[index],userId,posts[index]["id"]);
                        },
                      ),
                    ),

                  ],
                ),
              ),
            );
          } else {
            return const Text('No data found.');
          }
        }
      },
    );
  }
}