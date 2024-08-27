import 'package:authentication/Screens/User%20Screens/user_payment.dart';
import 'package:authentication/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authentication/widgets/order_item_widget.dart';
import 'package:flutter/widgets.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> allWhatWeGonnaBuy;

  const OrderDetailsPage({Key? key, required this.allWhatWeGonnaBuy}) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  double totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    calculateTotalCost();
  }

  void calculateTotalCost() {
    totalCost = 0.0;
    for (final item in widget.allWhatWeGonnaBuy) {
      final postDetails = item['postDetails'];
      final itemPriceperUnit = postDetails['itemPrice'];
      final desiredQuantity = item['quantity'];
      totalCost += itemPriceperUnit * desiredQuantity;
    }
  }

  Future<void> confirmOrder() async {
    try {
      // Iterate through all the items to be bought
      for (var item in widget.allWhatWeGonnaBuy) {
        String pageID = item['pageID'];
        String postID = item['postID'];
        int quantityToBuy = item['quantity'];
        // Get a reference to the product document
        DocumentReference productRef = FirebaseFirestore.instance
            .collection('providers')
            .doc(pageID)
            .collection('posts')
            .doc(postID);

        // Get the current quantityCounter value
        DocumentSnapshot productSnapshot = await productRef.get();
        int currentQuantity = (productSnapshot.data() as Map<String, dynamic>)['quantityCounter'];

        // Calculate the new quantityCounter value after buying
        int updatedQuantity = currentQuantity - quantityToBuy;

        // Check if the updated quantity is negative
        if (updatedQuantity < 0) {
          showToast(message: "You're ordering more than we have");
          return; // Exit the function if quantity is negative
        }

        // Update the quantityCounter in the Firestore database
        await productRef.update({'quantityCounter': updatedQuantity});
      }
    } catch (error) {
      // Handle errors
      showToast(message: 'Error confirming order: $error');
      // Optionally, show a toast message or handle the error in UI
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // List of order items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: widget.allWhatWeGonnaBuy.length,
                itemBuilder: (context, index) {
                  final item = widget.allWhatWeGonnaBuy[index];
                  final postDetails = item['postDetails'];
                  return OrderItemWidget(
                    imageUrl: postDetails['imageUrl'],
                    itemName: postDetails['itemName'],
                    itemPrice: postDetails['itemPrice'],
                        
                    quantity: item['quantity'],
                    color: item['selectedColor'],
                    size: item['selectedSize'],
                  );
                },
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                
                // // Total cost
                // Container(
                //     margin: const EdgeInsets.all(10.0),
                //     padding: const EdgeInsets.all(8.0),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align children to the start and end of the row
                //       children: [
                //         Text(
                //           'Total Cost : ',
                //           style: TextStyle(
                //             fontSize: 20,
                //             fontWeight: FontWeight.w500,
                //             color: Color(0xFF0D0A35),
                //           ),
                //         ),
                //         Text(
                //           '${totalCost.toStringAsFixed(2)} EGP', // Assuming "EGP" is the currency
                //           style: TextStyle(
                //             fontSize: 20,
                //             fontWeight: FontWeight.w500,
                //             color: Color(0xFF0D0A35),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),


                GestureDetector(
                  onTap: () {
                    // Navigate to next page and proceed the logic

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentPage(allWhatWeGonnaBuy: widget.allWhatWeGonnaBuy),
                      ),
                    );
                    
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
                        Text(
                          'Payment',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0D0A35),
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_right_alt_rounded,
                          color:Color(0xFF0D0A35),
                        ),
                        
                      ],
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
