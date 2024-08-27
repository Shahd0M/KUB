import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Main Screens/full_screen_img.dart';

class BrandPostDetails extends StatefulWidget {
  final Map<String, dynamic> postDetails;
  final String userID;
  final String postID;
  final String pageID;

  const BrandPostDetails(
    this.postDetails,
    this.userID,
    this.postID,
    this.pageID,
  );

  @override
  State<BrandPostDetails> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<BrandPostDetails> {
  bool addedToCart = false; // Track if item is added to cart

  // Function to check if the postID is already in the user's cart
// Function to check if the postID is already in the user's cart
Future<bool> isPostInCart(String userID, String postID) async {
  try {
    // Get a reference to the user document
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userID).get();

    // Check if the user document exists and contains the 'cart' field
    if (userDoc.exists && userDoc.data() != null && userDoc.data()!['cart'] != null) {
      // Explicitly cast 'cart' field to List<dynamic>
      List<dynamic> cart = userDoc.data()!['cart'] as List<dynamic>;
      // Check if postID is present in the cart
      return cart.any((item) => item['postID'] == postID);
    } else {
      return false; // Cart is empty or not found
    }
  } catch (e) {
    print('Error checking cart: $e');
    throw e; // Rethrow the error for handling in UI
  }
}

  void checkIfInCart() async {
    try {
      bool inCart = await isPostInCart(widget.userID, widget.postID);
      setState(() {
        addedToCart = inCart;
      });
    } catch (e) {
      print('Error checking cart: $e');
      // Handle error as needed
    }
  }

  // Function to update the user document in Firestore
void toggleCartState(String userID, String postID, String pageID, bool addedToCart) {
  try {
    if (!addedToCart) {
      // If addedToCart is true, remove the post from the cart
      removeFromCart(userID, postID, pageID);
    } else {
      // If addedToCart is false, add the post to the cart
      addToCart(userID, postID, pageID);
    }
  } catch (e) {
    print('Error toggling cart state: $e');
    throw e; // Rethrow the error for handling in UI
  }
}

// Function to add a post to the cart with pageID
Future<void> addToCart(String userID, String postID, String pageID) async {
  try {
    // Get a reference to the user document
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userID);

    // Update the 'cart' field by adding the postID and pageID as an object to the list
    await userDocRef.update({
      'cart': FieldValue.arrayUnion([
        {'postID': postID, 'pageID': pageID} // Add both postID and pageID
      ])
    });
  } catch (e) {
    print('Error adding to cart: $e');
    throw e; // Rethrow the error for handling in UI
  }
}

// Function to remove a post from the cart
Future<void> removeFromCart(String userID, String postID, String pageID) async {
  try {
    // Get a reference to the user document
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userID);

    // Update the 'cart' field by removing the object containing postID and pageID from the list
    await userDocRef.update({
      'cart': FieldValue.arrayRemove([
        {'postID': postID, 'pageID': pageID} // Remove both postID and pageID
      ])
    });
  } catch (e) {
    print('Error removing from cart: $e');
    throw e; // Rethrow the error for handling in UI
  }
}


@override
void initState() {
  super.initState();
  checkIfInCart();
}

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.postDetails['imageUrl'] ?? '';
    String itemName = widget.postDetails['itemName'] ?? '';
    String itemDescription = widget.postDetails['itemDescription'] ?? '';
    double itemPrice = widget.postDetails['itemPrice'] ?? '';
    int quantityCounter = widget.postDetails['quantityCounter'] ?? '';
    List<dynamic> selectedColors = widget.postDetails['selectedColors'] ?? [];
    List<dynamic> selectedSize = widget.postDetails['selectedSize'] ?? [];

    return Container(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color.fromRGBO(230, 222, 222, 100),
            title: Text(itemName),
          ),
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
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                SizedBox(height: 20),
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
                SizedBox(height: 20),
                Text(
                  'Available Colors',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 4.0),
                Wrap(
                  spacing: 8.0,
                  children: selectedColors
                      .map(
                        (color) => Chip(
                          label: Text(
                            color.toString(),
                            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 20.0),
                Text(
                  'Available Sizes',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 4.0),
                Wrap(
                  spacing: 8,
                  children: selectedSize
                      .map(
                        (size) => Chip(
                          label: Text(
                            size.toString(),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.grey[200],
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 20),
                // Add to cart button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      addedToCart = !addedToCart; // Toggle the state
                    });
                    toggleCartState(widget.userID, widget.postID, widget.pageID, addedToCart); // Call addToCart function
                  },
                  child: Container(
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: addedToCart ? Color(0xFF0D0A35) : Color.fromRGBO(255, 198, 50, 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          addedToCart ? Icons.check : Icons.shopping_cart,
                          color: addedToCart ? Color.fromRGBO(255, 198, 50, 1.0) : Color(0xFF0D0A35),
                        ),
                        SizedBox(width: 8),
                        Text(
                          addedToCart ? 'Added' : 'Add to Cart',
                          style: TextStyle(
                            fontSize: 16,
                            color: addedToCart ? Color.fromRGBO(255, 198, 50, 1.0) : Color(0xFF0D0A35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _infoCube(BuildContext context, String title, String value) {
  return Container(
    width: double.infinity,
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
            color: Color(0xFF0D0A35),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: Color(0xFF0D0A35),
            fontSize: 18,
          ),
        ),
      ],
    ),
  );
}
