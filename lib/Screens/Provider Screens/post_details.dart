import 'package:authentication/Screens/Main%20Screens/full_screen_img.dart';
import 'package:authentication/Screens/Provider%20Screens/edit_post.dart';
import 'package:authentication/Screens/Provider%20Screens/provider_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class PostDetailsPage extends StatefulWidget {
  final Map<String, dynamic> postDetails;
  final String userID;
  final String postID;

  const PostDetailsPage(
      this.postDetails,
      this.userID,
      this.postID,
      );

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {

  

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.postDetails['imageUrl'] ?? '';
    String itemName = widget.postDetails['itemName'] ?? '';
    String itemDescription = widget.postDetails['itemDescription'] ?? '';
    double itemPrice = widget.postDetails['itemPrice'] ?? '';
    int quantityCounter = widget.postDetails['quantityCounter'] ?? '';
    List<dynamic> selectedColors = widget.postDetails['selectedColors'] ?? [];
    List<dynamic> selectedCategory = widget.postDetails['selectedCategory'] ?? [];
    List<dynamic> selectedSize = widget.postDetails['selectedSize'] ?? [];
    print('post id : ${widget.postID}');

    return Container(
      color: Colors.white,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Color(0xFF4E310F),),
                    onPressed: () {
                      // Call function to delete document
                      deleteItemFromFirebase(widget.userID , widget.postID);
                    },
                  ),
                ),
              ],
              backgroundColor: Color.fromRGBO(230, 222, 222, 100),
              title: const Text('Post Details' ,
                style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(imageUrl: imageUrl),
                        ),
                      );
                    },

                    child: Center(
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPostPage(
                            postDetails: widget.postDetails,
                            userID: widget.userID,
                            postID: widget.postID,

                          ),
                        ),
                      );
                    },
                    child : Container(
                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          border: Border.all(color:Color.fromRGBO(230, 222, 222, 100)
                              , width: 2.0),
                          // No such attribute
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Wrap(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 7,),
                              Text('Edit post' , style: TextStyle(
                                      fontSize: 16 , fontWeight: FontWeight.bold
                                  ),
                              ),
                            ],
                          )
                        ),
                        // child: Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child:  IconButton(
                        //       onPressed: (){},
                        //       icon: Icon(Icons.edit , )
                        //   ,
                        //   ),
                        //   // child: Text('edit post' , style: TextStyle(
                        //   //     fontSize: 16 , fontWeight: FontWeight.bold
                        //   // ),
                        //   // ),
                        // ),
                    ),

                  ),
                  SizedBox(height: 20),
                  // the 2 boxes (quantity & avg price)
                  Container(
                    width: double.infinity, // Ensure the container takes the full width of the screen
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust alignment as needed
                      children: [
                        Expanded(
                          child: _infoCube(context, 'Quantity', quantityCounter.toString()),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: _infoCube(context, 'Price', itemPrice.toString()),
                        ),
                      ],
                    ),
                  ),


                  SizedBox(height: 23),
                  Text(
                    itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    itemDescription,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Colors',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15.0),
                  Wrap(
                    spacing: 8.0,
                    children: selectedColors
                        .map((color) => Chip(
                      label: Text(
                        color.toString(),
                        style: TextStyle(fontSize: 15.0 ,
                            fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.grey[200],

                    ))
                        .toList(),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Categories',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15.0),
                  Wrap(
                    spacing: 15,
                    children: selectedCategory
                        .map((category) => Chip(
                      label: Text(
                        category.toString(),
                        style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.grey[200],
                    ))
                        .toList(),
                  ),

                  SizedBox(height: 20.0),
                  Text(
                    'Sizes',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15.0),
                  Wrap(
                    spacing: 15,
                    children: selectedSize
                        .map((size) => Chip(
                      label: Text(
                        size.toString(),
                        style: TextStyle(fontSize: 15 , fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.grey[200],
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Future<void> deleteItemFromFirebase(String userID, String postID) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF7F4EB),
          title: Text(
            'Confirm',
            style: TextStyle(
              color: Color(0xFF4E310F),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this product?',
            style: TextStyle(
              color: Color(0xFF4E310F),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      try {
        // Delete the document
        await FirebaseFirestore.instance
            .collection('providers')
            .doc(userID)
            .collection("posts")
            .doc(postID)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Color(0xFF4E310F),
            content: Text('Product deleted successfully'),
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProviderHomeScreen(navBarIndex: 0),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting Product'),
          ),
        );
        print('Error deleting post: $e');
      }
    }
  }
}


Widget _infoCube(BuildContext context, String title, String value) {
  return Container(
    width: double.infinity, // Make the container take the full available width
    height: 100,
    margin: EdgeInsets.all(0),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}