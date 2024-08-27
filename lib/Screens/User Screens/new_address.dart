import 'package:authentication/Screens/User%20Screens/user_checkout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class newAddress extends StatefulWidget {
  double total=0.0;
  final List<Map<String, dynamic>> allWhatWeGonnaBuy;
  newAddress({required this.total,required this.allWhatWeGonnaBuy});

  @override
  State<newAddress> createState() => _newAddressState(total:total,allWhatWeGonnaBuy:allWhatWeGonnaBuy);
}

class _newAddressState extends State<newAddress> {
  double total=0.0;
  final List<Map<String, dynamic>> allWhatWeGonnaBuy;
  _newAddressState({required this.total, required this.allWhatWeGonnaBuy});
  final AddreesController = TextEditingController();
  final BuildingnumberController = TextEditingController();
  final FloorController = TextEditingController();
  final FlatController = TextEditingController();



  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  List<String> _addresses = [];

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
    }
  }


  void _getUserAddresses(String uid) async {
    DocumentSnapshot userDoc = await _firestore.collection('users')
        .doc(uid)
        .get();
    if (userDoc.exists) {
      List<Map<String,String>> addresses = userDoc.get('addresses') ?? [];
      setState(() {
        _addresses = addresses.map((address) => address.toString()).toList();
      });
    }
  }


  void _addNewAddress() async {
    if (_currentUser == null) return;

    String newAddress = AddreesController.text;
    String buildingnum = BuildingnumberController.text;
    String floornum = FloorController.text;
    String flatnumber = FlatController.text;

    if (newAddress.isNotEmpty && buildingnum.isNotEmpty && floornum.isNotEmpty
    && flatnumber.isNotEmpty) {
      Map<String, String> newAddressEntry = {
        'Address': newAddress,
        'Building Num': buildingnum,
        'Floor' : flatnumber ,
        'Flat' : flatnumber
      };
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'addresses': FieldValue.arrayUnion([newAddressEntry])
      });
      // Update the local list of addresses
      setState(() {
        _addresses.add(newAddress);
      });

      // Clear the input field
      AddreesController.clear();
      BuildingnumberController.clear();
      FloorController.clear();
      FlatController.clear();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check out')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Address form
            Form(
              child:
              Column(
                children: [
                  TextFormField(
                    controller: AddreesController,
                    decoration: InputDecoration(labelText: 'Address name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address name';
                      }
                    },
                  ),
                  TextFormField(
                    controller: BuildingnumberController,
                    decoration: InputDecoration(labelText: 'Building#'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your building number or name';
                      }
                    },
                  ),
                  TextFormField(
                    keyboardType:
                    TextInputType.phone, //To make the input only numbers
                    controller: FloorController,
                    decoration: InputDecoration(labelText: 'Floor#'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your floor number';
                      }
                    },
                  ),
                  TextFormField(
                    keyboardType:
                    TextInputType.phone, //To make the input only numbers
                    controller: FlatController,
                    decoration: InputDecoration(labelText: 'Flat#'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your flat number';
                      }
                    },
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _addNewAddress();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserCheckout(total: total,allWhatWeGonnaBuy:allWhatWeGonnaBuy),
                        ),
                      );
                    },
                    child: Text('Add Address'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
