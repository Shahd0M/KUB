import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Screens/User Screens/user_brand_posts.dart';

class BrandPosts extends StatefulWidget {

  final Map<String, dynamic> postDetails;
  final String userID;
  final String postID;
  final String pageID;

  BrandPosts(
    this.postDetails,
    this.userID,
    this.postID,
    this.pageID,
  );

  @override
  State<BrandPosts> createState() => _BrandPostsState();
}

class _BrandPostsState extends State<BrandPosts> {

  bool favButton = false;

  Future<bool> isPostFavorite(String userID, String postID) async {
    try {
      // Get a reference to the user document
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userID).get();

      // Check if the user document exists and contains the 'favs' field
      if (userSnapshot.exists && userSnapshot.data()!.containsKey('favs')) {
        // Get the 'favs' list from the user document
        List<dynamic> favs = List.from(userSnapshot.data()!['favs']);

        // Check if the 'favs' list contains a map with the given postID
        bool isFavorite = favs.any((fav) => fav['postID'] == postID);

        return isFavorite;
      } else {
        // If the user document or 'favs' field doesn't exist, return false
        return false;
      }
    } catch (e) {
      // Handle any errors and return false
      print('Error checking favorite: $e');
      return false;
    }
  }

  Future<void> toggleFavorite(String userID, String postID) async {
    try {
      // Get a reference to the user document
      DocumentReference<Map<String, dynamic>> userDocRef = FirebaseFirestore.instance.collection('users').doc(userID);

      // Get the current favorites list
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocRef.get();
      List<dynamic> favs = List.from(userSnapshot.data()!['favs'] ?? []);

      // Check if the post is already in the favorites list
      bool isFavorite = favs.any((fav) => fav['postID'] == postID);

      if (isFavorite) {
        // If the post is already in the favorites list, remove it
        favs.removeWhere((fav) => fav['postID'] == postID);
      } else {
        // If the post is not in the favorites list, add it
        favs.add({'postID': postID, 'pageID': widget.pageID});
      }

      // Update the favorites list in the user document
      await userDocRef.update({'favs': favs});

      // Update the favButton state variable
      setState(() {
        favButton = !isFavorite;
      });
    } catch (e) {
      // Handle errors
      print('Error toggling favorite: $e');
    }
  }


  
  @override
  void initState() {
    super.initState();
    // Call isPostFavorite to determine if the post is in the favorites list
    isPostFavorite(widget.userID, widget.postID).then((isFavorite) {
      setState(() {
        // Update the favButton state variable
        favButton = isFavorite;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BrandPostDetails(
              widget.postDetails,
              widget.userID,
              widget.postID,
              widget.pageID,
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // Specify the border radius
              image: DecorationImage(
                image: NetworkImage(widget.postDetails['imageUrl'] ?? ''),
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Toggle the favorite status when the heart button is pressed
              toggleFavorite(widget.userID, widget.postID);
            },
            icon: Icon(
              Icons.favorite,
              // Change the color based on the favButton state variable
              color: favButton ? Colors.red : Colors.white,
              size: 25,
            )
          )
        ],
      ),
    );
  }
}
