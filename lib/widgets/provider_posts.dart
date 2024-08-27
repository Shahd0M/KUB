import 'package:authentication/Screens/Provider%20Screens/post_details.dart';
import 'package:flutter/material.dart';

class ProviderPosts extends StatelessWidget {
  final Map<String , dynamic> postDetails;
  final String userID;
  final String postID;


  ProviderPosts(
      this.postDetails,
      this.userID,
      this.postID,
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsPage(
              postDetails,
              userID,
              postID,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), // Specify the border radius
          image: DecorationImage(
            image: NetworkImage(postDetails['imageUrl'] ?? ''),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
