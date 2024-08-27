import 'package:authentication/Screens/User%20Screens/user_home_screen.dart';
import 'package:authentication/Screens/User%20Screens/user_checkout.dart';
import 'package:authentication/main.dart';
import 'package:authentication/widgets/order_item_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> allWhatWeGonnaBuy;

  const PaymentPage({Key? key, required this.allWhatWeGonnaBuy}) : super(key: key);

  @override
  State<PaymentPage> createState() => PaymentPageState(allWhatWeGonnaBuy:allWhatWeGonnaBuy);
}

class PaymentPageState extends State<PaymentPage> {
    double totalCost = 0.0;
    final List<Map<String, dynamic>> allWhatWeGonnaBuy;
    PaymentPageState({required this.allWhatWeGonnaBuy});
  @override
  void initState() {
    super.initState();
    calculateTotalCost();
  }

    void calculateTotalCost() {
      for (final item in widget.allWhatWeGonnaBuy) {
        final postDetails = item['postDetails'];
        final itemPriceperUnit = postDetails['itemPrice'];
        final desiredQuantity = item['quantity'];
        totalCost += itemPriceperUnit * desiredQuantity;
      }
    }

 Future<void> confirmOrder(BuildContext context) async {
  try {
    // Construct the order data
    List<Map<String, dynamic>> orderItems = widget.allWhatWeGonnaBuy.map((item) {
      return {
        'postID': item['postID'],
        'postDetails': item['postDetails'],
        'selectedColor': item['selectedColor'],
        'selectedSize': item['selectedSize'],
        'quantity': item['quantity'],
      };
    }).toList();

    // Get the current date and time
    DateTime now = DateTime.now();

    // Format the date in the desired format
    String formattedDate = DateFormat('MMM d y, hh:mm a').format(now);

    // Save the order details to Firestore
    await FirebaseFirestore.instance.collection('orders').add({
      'pageID': widget.allWhatWeGonnaBuy.first['pageID'], // Assuming all items have the same pageID
      'userID': widget.allWhatWeGonnaBuy.first['userID'],
      'items': orderItems,
      'status': 'pending',
      'date': formattedDate, // Add the formatted date to the document
    });

    print(orderItems);

    // Show a dialog with a checkmark icon to indicate successful order confirmation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
              SizedBox(width: 10),
              Text('Order Confirmed', style: TextStyle(color: Colors.green)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to the home screen after the user acknowledges the confirmation
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserHomeScreen(navBarIndex: 0),
                  ),
                  (route) => false, // Pass a function that always returns false to remove all routes
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

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
        title: Text('Payment'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
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
              SizedBox(height: 20),

              // Total cost
                Container(
                    margin: const EdgeInsets.all(10.0),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align children to the start and end of the row
                      children: [
                        Text(
                          'Total Cost : ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0D0A35),
                          ),
                        ),
                        Text(
                          '${totalCost.toStringAsFixed(2)} EGP', // Assuming "EGP" is the currency
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0D0A35),
                          ),
                        ),
                      ],
                    ),
                  ),

              GestureDetector(
                // onTap: () {
                //   // Navigate to next page and proceed the logic
                //   confirmOrder(context);
                // },
                onTap: () {
                  // Navigate to next page and proceed the logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  UserCheckout(total: totalCost, allWhatWeGonnaBuy:allWhatWeGonnaBuy,),
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
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0D0A35),
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.done,
                        color:Color(0xFF0D0A35),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
