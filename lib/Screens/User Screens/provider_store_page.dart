import 'package:authentication/Screens/User%20Screens/user_chat_with_provider.dart';
import 'package:authentication/Screens/User%20Screens/user_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../Design/Provider_categories_Design.dart';
import '../../widgets/brand_posts.dart';

class ProviderScreen extends StatefulWidget {
  String? pageName;
  ProviderScreen({super.key, required this.pageName});

  @override
  State<ProviderScreen> createState() => ProviderStoreScreenContentState();
}

class ProviderStoreScreenContentState extends State<ProviderScreen> {
  List brandPages=[];
  List<dynamic> _providerCategories = [];
  List<String> _subCategories = [];

  String brandPageName="";
  String brandPageImage="";
  bool isFollowing=false;
  int followersCount=0;
  int postsCount = 0;
  String? uid;
  String brandPageId='';
  String pageID="";

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    this.uid = uid;
    return await userRef.get();
  }

  @override
  void initState() {
    getProvidersPages();
    getUserData();
    countFollowers();
    getPosts();
    _fetchUserCategories();
    super.initState();
  }

  getProvidersPages() async {
    var data = await FirebaseFirestore.instance
        .collection("providers")
        .orderBy("username")
        .get();
    setState(() {
      brandPages = data.docs;
    });
    searchBrandPage(brandPages);
  }

  Future<void> countFollowers() async {
    try {
      // Retrieve brand document
      QuerySnapshot followersRec = await FirebaseFirestore.instance
          .collection('providers')
          .where('username', isEqualTo: widget.pageName)
          .get();

      DocumentSnapshot? brandDoc;
      for (DocumentSnapshot doc in followersRec.docs) {
        if (doc['username'] == widget.pageName) {
          brandDoc = doc;
          break;
        }
      }
      if (brandDoc != null) {
        String  brandPageId = brandDoc.id;
        pageID=brandPageId;
        DocumentSnapshot updatedBrandDoc = await FirebaseFirestore.instance.collection('providers').doc(brandPageId).get();
        //Map<String, dynamic> _providerData = updatedBrandDoc.data() as Map<String, dynamic>;
        //posts = _providerData.isNotEmpty ? _providerData['posts'] ?? [] : [];
        postsCount = posts!.length;
        print('number of posts : $postsCount');

        // Get followers count
        List<dynamic> followers = updatedBrandDoc['followers'];

        // Fetch user document
        DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
        DocumentSnapshot userDoc = await userRef.get();

        // Check if the user is following
        dynamic data = userDoc.data();
        List following = List.from(data['following'] ?? []);

        setState(() {
          isFollowing = following.contains(brandPageId);
          followersCount = followers.length;
        });
        print("Followers Count: $followersCount");
        print("Is Following: $isFollowing");
      } else {
        print("Brand document not found for $brandPageName");
      }
    } catch (e) {
      print("Error: $e");
      // Handle error as needed
    }
  }

  searchBrandPage(List brandPages) async{
    if(widget.pageName!=null) {
      for (int index = 0; index < brandPages.length; index++) {
        if (brandPages[index]["username"] == widget.pageName!) {
          brandPageName = brandPages[index]["username"];
          brandPageImage = brandPages[index]["LogoURL"];
        }
      }
    }
  }

  List<dynamic> posts = [];

  getPosts() async {
    String?  brandPageId;
    QuerySnapshot followersRec = await FirebaseFirestore.instance
        .collection('providers')
        .where('username', isEqualTo: widget.pageName)
        .get();

    DocumentSnapshot? brandDoc;
    for (DocumentSnapshot doc in followersRec.docs) {
      if (doc['username'] == widget.pageName) {
        brandDoc = doc;
        break;
      }
    }
    if (brandDoc != null) {
      brandPageId = brandDoc.id;
    }
    await FirebaseFirestore.instance
        .collection('providers')
        .doc(brandPageId)
        .collection('posts')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> postData = doc.data() as Map<String, dynamic>;
        postData['id'] = doc.id; // Add document ID to the postData
        posts.add(postData);
        postsCount=posts.length;
        print(posts);
      });
    }).catchError((error) {
      print("Error getting posts: $error");
    });
  }


  Future<void> _fetchUserCategories() async {
    try {
      QuerySnapshot followersRec = await FirebaseFirestore.instance
          .collection('providers')
          .where('username', isEqualTo: widget.pageName)
          .get();

      DocumentSnapshot? brandDoc;
      for (DocumentSnapshot doc in followersRec.docs) {
        if (doc['username'] == widget.pageName) {
          brandDoc = doc;
          break;
        }
      }
      if (brandDoc != null) {
        brandPageId = brandDoc.id;
      }
      // Fetch the provider document for the current user
      DocumentSnapshot<Map<String, dynamic>> providerSnapshot =
      await FirebaseFirestore.instance.collection('providers').doc(brandPageId).get();

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

  Future<void> toggleFollowStatus() async {
    try {
      // Query the 'providers' collection to find the document with the matching name
      QuerySnapshot querySnapshot = await FirebaseFirestore
          .instance
          .collection('providers')
          .where('username', isEqualTo: brandPageName)
          .get();
      // Iterate over the documents in the query result to find the one with the matching name
      DocumentSnapshot? brandDoc;
      for (DocumentSnapshot doc in querySnapshot.docs) {
        if (doc['username'] == brandPageName) {
          brandDoc = doc;
          break;
        }
      }

      if (brandDoc != null) {
        // Get the document ID
        String brandPageId = brandDoc.id;

        // Fetch user document
        DocumentReference userRef = FirebaseFirestore
            .instance
            .collection('users')
            .doc(uid);
        DocumentSnapshot userDoc = await userRef.get();

        // Extract 'following' array from user document
        dynamic data = userDoc.data();
        List following = List.from(data['following'] ?? []);

        if (following.contains(brandPageId)) {
          // If the user is already following the brand, unfollow it
          await userRef.update({
            'following': FieldValue.arrayRemove([brandPageId])
          });

          // Fetch brand (service provider) document
          DocumentReference brandRef = FirebaseFirestore
              .instance
              .collection('providers')
              .doc(brandPageId);
          await brandRef.update({
            'followers': FieldValue.arrayRemove([uid])
          });

          // Update followersCount after unfollowing
          DocumentSnapshot updatedBrandDoc = await brandRef.get();
          List<dynamic> followers = updatedBrandDoc['followers'];
          setState(() {
            isFollowing = false;
            followersCount = followers.length;
          });
        } else {
          // If the user is not following the brand, follow it
          await userRef.update({
            'following': FieldValue.arrayUnion([brandPageId])
          });

          // Fetch brand (service provider) document
          DocumentReference brandRef = FirebaseFirestore
              .instance
              .collection('providers')
              .doc(brandPageId);
          await brandRef.update({
            'followers': FieldValue.arrayUnion([uid])
          });

          // Update followersCount after following
          DocumentSnapshot updatedBrandDoc = await brandRef.get();
          List<dynamic> followers = updatedBrandDoc['followers'];
          setState(() {
            isFollowing = true;
            followersCount = followers.length;
          });
        }

        print("Number of followers for $brandPageName: $followersCount");
        // Update the button text to include the follower count
        print("Follow/unfollow operation completed successfully.");
      } else {
        print("No document found for $brandPageName");
      }
    } catch (e) {
      print("Error: $e");
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            iconSize: 32,
            onPressed: () {},
            icon: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    UserHomeScreen(navBarIndex: 0)));
              },
              child: Icon(
                Icons.arrow_back_rounded,
                color: Colors.black,
              ),
            )
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 22, top: 10),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(
                      brandPageImage,
                    ),
                  ),
                  SizedBox(width: 25,),
                  Text(
                    brandPageName,
                    style: TextStyle(color: Colors.black, fontSize: 24),
                    // style: Theme.of(context).textTheme.headline4,
                  ),
                  SizedBox(height: 10,),   
                ],
              ),
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      "${postsCount}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Posts",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 50, height: 20),
                Column(
                  children: [
                    Text(
                      "${followersCount}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Followers",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Container(
              margin: EdgeInsets.all(15), //follow and chat buttons
              // width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  GestureDetector(
                    onTap: toggleFollowStatus,
                    child: Container(
                      width: 130,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color: isFollowing ? Colors.grey : Color.fromARGB(255, 13, 10, 83),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isFollowing ? 'Unfollow' : 'Follow',
                        style: TextStyle(
                          color: isFollowing ? Colors.black : Colors.white,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // add chat logic
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  UserChatWithProviderScreen(providerId: brandPageId,)));
                    },
                    child: Container(
                      width: 130,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      decoration: BoxDecoration(
                        color:Color.fromARGB(255, 13, 10, 83),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                          'Chat',
                          style: TextStyle(color: Colors.white , fontSize:15),
                          textAlign: TextAlign.center,
                        ),
                    ),
                  ),

                  
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 10),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Categories",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
              ),
            ),
            // Categories design
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
            Container(
                margin: const EdgeInsets.only(left: 15,),
                alignment: Alignment.centerLeft,
                child: const Text("Posts",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),)
            ),
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
                  print(pageID);
                  return BrandPosts(posts[index],uid!,posts[index]['id'],pageID);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}





