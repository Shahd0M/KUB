import 'package:authentication/Screens/User%20Screens/payment_method_screen.dart';
import 'package:authentication/Screens/User%20Screens/user_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import 'new_address.dart';

class UserCheckout extends StatefulWidget {
  double total=0.0;
  final List<Map<String, dynamic>> allWhatWeGonnaBuy;

  UserCheckout({required this.total,required this.allWhatWeGonnaBuy});
  @override
  _UserCheckoutState createState() => _UserCheckoutState(total,allWhatWeGonnaBuy);
}

class _UserCheckoutState extends State<UserCheckout> {
  double total=0.0;
  final List<Map<String, dynamic>> allWhatWeGonnaBuy;
  _UserCheckoutState(this.total,this.allWhatWeGonnaBuy);


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;

  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> _carddetails = [];
  int? _selectedAddress;
  int? _selectedCard;
  int idAddress=0;
  int idCart=0;

  bool isCash=false;
  bool value = false;

  bool? check1 = false; //true for checked checkbox, false for unchecked one

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
      _getUserAddresses(user.uid);
      _getUserCards(user.uid);
    }
  }

  void _getUserAddresses(String uid) async {
    DocumentSnapshot userDoc =
    await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      List<dynamic> addresses = userDoc.get('addresses') ?? [];
      setState(() {
        _addresses = List<Map<String, dynamic>>.from(
          addresses.map(
                (address) => Map<String, dynamic>.from(address),
          ),
        );
      });
    }
  }

  void _getUserCards(String uid) async {
    DocumentSnapshot userDoc =
    await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      List<dynamic> carddetails = userDoc.get('cards') ?? [];
      setState(() {
        _carddetails = List<Map<String, dynamic>>.from(
          carddetails.map(
                (carddetailss) => Map<String, dynamic>.from(carddetailss),
          ),
        );
      });
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

      double totalAfterDelivery=total+20;
      // Format the date in the desired format
      String formattedDate = DateFormat('MMM d y, hh:mm a').format(now);

      // Save the order details to Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'pageID': widget.allWhatWeGonnaBuy.first['pageID'], // Assuming all items have the same pageID
        'userID': widget.allWhatWeGonnaBuy.first['userID'],
        'items': orderItems,
        'status': 'pending',
        'date': formattedDate,
        'address':_addresses[idAddress],
        'cards':_carddetails[idCart],
        'PaymentMethod':"Online",
        'Total':totalAfterDelivery,// Add the formatted date to the document
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


  Future<void> confirmOrderForCash(BuildContext context) async {
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
      double totalAfterDelivery=total+20;
      // Save the order details to Firestore
      await FirebaseFirestore.instance.collection('orders').add({
        'pageID': widget.allWhatWeGonnaBuy.first['pageID'], // Assuming all items have the same pageID
        'userID': widget.allWhatWeGonnaBuy.first['userID'],
        'items': orderItems,
        'status': 'pending',
        'date': formattedDate,
        'address':_addresses[idAddress],
        // Add the formatted date to the document
        'PaymentMethod':"Cash",
        'Total':totalAfterDelivery,
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
    //double totalCost = PaymentPage(allWhatWeGonnaBuy: allWhatWeGonnaBuy).calculateTotalCost();
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body:
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                  Container(
                    height:  MediaQuery.of(context).size.height*0.22,
                    width: MediaQuery.of(context).size.height*0.47,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Text('Address Details' ,
                          style: TextStyle(color: Colors.white , fontSize:23,fontWeight: FontWeight.w400),),
                        _currentUser != null
                            ? _addresses.isNotEmpty
                            ? Expanded(
                          child: ListView.builder(
                            itemCount: _addresses.length,
                            itemBuilder: (context, index) {
                              final address = _addresses[index];
                              return  RadioListTile<int>(
                                  value: index,
                                  groupValue: _selectedAddress,
                                  onChanged: (int? value) {
                                    idAddress=index;
                                setState(() {
                                  _selectedAddress = value;
                                });
                              },
                                title: Text( '${address['Address'] ?? 'No Address name'}' ,
                                  style: TextStyle(color: Colors.white
                                      , fontWeight: FontWeight.bold ,
                                      fontSize: 20),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Buliding number is ${address['Building Num'] ?? 'No Builiding name'}' ,
                                      style: TextStyle(color: Colors.white , fontWeight: FontWeight.w400),),
                                    SizedBox(height: 5,),
                                    Text('Floor number -->  ${address['Floor'] ?? 'No floor number'}' ,
                                      style: TextStyle(color: Colors.white , fontWeight: FontWeight.w400),),
                                    SizedBox(height: 5,),
                                    Text('Flat number --> ${address['Flat'] ?? 'No flat number'}' ,
                                      style: TextStyle(color: Colors.white , fontWeight: FontWeight.w400),),
                                  ],
                                ),
                              );
            
                            },
                          ),
                        )
                            : Center(
                          child: Text('No addresses found.'),
                        )
                            : Center(
                          child: CircularProgressIndicator(),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => newAddress(total: total,allWhatWeGonnaBuy:allWhatWeGonnaBuy),
                              ),
                            );
                          },
                          child: Text('Add Address'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                  Container(
                    height:  MediaQuery.of(context).size.height*0.22,
                    width: MediaQuery.of(context).size.height*0.47,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      children: [
                        Text('Card Details' ,
                          style: TextStyle(color: Colors.white , fontWeight: FontWeight.w400),),
                        _currentUser != null
                            ? _carddetails.isNotEmpty
                            ? Expanded(
                          child: ListView.builder(
                            itemCount: _carddetails.length,
                            itemBuilder: (context, index) {
                              final cardss = _carddetails[index];
                              return RadioListTile<int>(
                                  value: index,
                                  groupValue: _selectedCard,
                                  onChanged: (int? value) {
                                    idCart=index;
                                setState(() {
                                  _selectedCard = value;
                                });
                              },
                                title: Text( '${cardss['Card Holder'] ?? 'No Card Holder Name'}' ,
                                  style: TextStyle(color: Colors.white
                                      , fontWeight: FontWeight.bold ,
                                      fontSize: 20),),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Your card number is  ${cardss['Card Name'] ?? 'No card number is saved'}' ,
                                      style: TextStyle(color: Colors.white , fontWeight: FontWeight.w400),),
                                    SizedBox(height: 5,),
                                    Text('Expiry date of the card is ${cardss['Expiry Date'] ?? 'No Data is found'}' ,
                                      style: TextStyle(color: Colors.white , fontWeight: FontWeight.w400),),
                                    SizedBox(height: 5,),
                                    Text('Your Cvv is  ${cardss['CVV'] ?? 'No CVV is saved'}' ,
                                      style: TextStyle(color: Colors.white , fontWeight: FontWeight.w400),),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                            : Center(
                          child: Text('No addresses found.'),
                        )
                            : Center(
                          child: CircularProgressIndicator(),
                        ),
            
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentMethod(total: total,allWhatWeGonnaBuy:allWhatWeGonnaBuy),
                              ),
                            );
                          },
                          child: Text('Add Card'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.money , color: Colors.green,size: 30,) ,
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text ('Or Pay Cash' ,
                          style: TextStyle(fontWeight: FontWeight.bold ,
                              fontSize: 23),),
                      ),
                      const Spacer(),
                    Checkbox( //only check box
                    value: check1, //unchecked
                    onChanged: (bool? value){
                      //value returned when the checkbox is clicked
                      setState(() {
                        check1 = value;
                      });
                      isCash=true;
                    }
                )

              ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text('Order Summary ' , style: TextStyle(
                          fontWeight: FontWeight.bold ,
                          fontSize: 23
                      ),
                      ),
                      const Spacer(),
                      IconButton(onPressed: (){},
                        icon: const Icon(Icons.keyboard_arrow_down ,
                          size: 30 ,) ,
            
                      )
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * .99,
                      height:MediaQuery.of(context).size.height * .30,
                      decoration:
                      BoxDecoration(
                        color: const Color.fromRGBO(13, 10, 53, 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children:  [
                            Padding(
                              padding: EdgeInsets.all(18),
                              child:
                              Text('Sub Total' ,
                                style: TextStyle(color: Colors.white ,
                                    fontWeight: FontWeight.bold ,
                                    fontSize: 20),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.all(18),
                              child:
                              Text('${total} L.E' ,
                                style: TextStyle(color: Colors.white ,
                                    fontWeight: FontWeight.w500 ,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(18),
                              child:
                              Text('Delivery Fee',
                                style: TextStyle(color: Colors.white ,
                                    fontWeight: FontWeight.bold ,
                                    fontSize: 20),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.all(18),
                              child:
                              Text('20 L.E',
                                style: TextStyle(color: Colors.white ,
                                    fontWeight: FontWeight.w500 ,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(18),
                              child:
                              Text('Total Amount',
                                style: TextStyle(color: Colors.white ,
                                    fontWeight: FontWeight.bold ,
                                    fontSize: 20),
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.all(18),
                              child:
                              Text('${total+20} L.E',
                                style: TextStyle(color: Colors.white ,
                                    fontWeight: FontWeight.w500 ,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to next page and proceed the logic
                            isCash?confirmOrderForCash(context):confirmOrder(context);
                          },
            
                          child: Container(
                            width: MediaQuery.of(context).size.width * .60,
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(255, 198, 50, 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Order Confirmed',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF0D0A35),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.done,
                                  color:Color(0xFF0D0A35),
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
              ],
            ),
          ),
    );
  }
}