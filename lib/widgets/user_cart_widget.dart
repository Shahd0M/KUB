import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartItemWidget extends StatefulWidget {
  final Map<String, dynamic> postDetails;
  final String userID;
  final String postID;
  final String pageID;

  final Function(Map<String, dynamic>) onItemDetailsChanged;

  const CartItemWidget({
    required this.postDetails,
    required this.userID,
    required this.postID,
    required this.pageID,
    required this.onItemDetailsChanged,
  });

  @override
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  String? selectedColor;
  String? selectedSize;
  int quantity = 1; // Initial quantity

  // Function to decrease quantity
  void decreaseQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
        updateItemDetails();
      }
    });
  }

  // Function to increase quantity
  void increaseQuantity() {
    setState(() {
      if (quantity < widget.postDetails['quantityCounter']) {
        quantity++;
        updateItemDetails();
      }
    });
  }

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

  void updateItemDetails() {
    widget.onItemDetailsChanged({
      'postDetails': widget.postDetails,
      'userID': widget.userID,
      'postID': widget.postID,
      'pageID': widget.pageID,
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    });
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.postDetails['imageUrl'] ?? '';
    String itemName = widget.postDetails['itemName'] ?? '';
    double itemPrice = widget.postDetails['itemPrice'] ?? 0.0;
    List<dynamic> availableColors = widget.postDetails['selectedColors'] ?? [];
    List<dynamic> availableSizes = widget.postDetails['selectedSize'] ?? [];

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            children: [
              // Left side: Item image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 16),
              // Right side: Item details and controls

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4,),

                    Text(
                      'Price: ${itemPrice.toStringAsFixed(2)} EGP',
                      style: TextStyle(fontSize: 16),
                    ),

                  ],
                ),
              ),
              IconButton(
                onPressed:() {
                  removeFromCart(widget.userID, widget.postID, widget.pageID);
                },
                icon: Icon(Icons.delete),
              ),
            ],
          ),

          SizedBox(height: 12,),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF0D0A35)), // Dropdown border
                  borderRadius: BorderRadius.circular(8), // Dropdown border radius
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12), // Adjust padding as needed
                  child: DropdownButton<String>(
                    value: availableColors.isNotEmpty ? availableColors[0] : null,
                    items: availableColors
                        .map<DropdownMenuItem<String>>(
                          (color) => DropdownMenuItem<String>(
                        value: color.toString(),
                        child: Text(color.toString()),
                      ),
                    )
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedColor = newValue;
                        updateItemDetails();
                      });
                    },
                    style: TextStyle(color: Color(0xFF0D0A35)), // Text color
                    underline: Container(),
                    dropdownColor: Color.fromARGB(255, 255, 255, 255), // Set dropdown background color
                    borderRadius: BorderRadius.circular(10),
                    icon: Icon(Icons.arrow_drop_down_sharp, color: Color(0xFF0D0A35),), // Dropdown icon
                    iconSize: 28,
                    isExpanded: true,
                  ),
                ),
              ),
              SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF0D0A35)), // Dropdown border
                  borderRadius: BorderRadius.circular(8), // Dropdown border radius
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12), // Adjust padding as needed
                  child: DropdownButton<String>(
                    value: availableSizes.isNotEmpty ? availableSizes[0] : null,
                    items: availableSizes
                        .map<DropdownMenuItem<String>>(
                          (size) => DropdownMenuItem<String>(
                        value: size.toString(),
                        child: Text(size.toString()),
                      ),
                    )
                        .toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedSize = newValue;
                        updateItemDetails();
                      });
                    },

                    style: TextStyle(color: Color(0xFF0D0A35)), // Text color
                    underline: Container(),
                    dropdownColor: Color.fromARGB(255, 255, 255, 255), // Set dropdown background color
                    borderRadius: BorderRadius.circular(10),
                    icon: Icon(Icons.arrow_drop_down_sharp, color: Color(0xFF0D0A35),), // Dropdown icon
                    iconSize: 28,
                    isExpanded: true,
                  ),
                ),
              ),


              SizedBox(height: 8),

              // Quantity counter
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: decreaseQuantity,
                  ),
                  Text(quantity.toString()),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: increaseQuantity,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
