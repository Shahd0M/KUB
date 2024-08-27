import 'package:authentication/Screens/User%20Screens/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/provider.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({Key? key}) : super(key: key);
  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  late TextEditingController _usernameController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  //late TextEditingController _addressController = TextEditingController();

  String? userID;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    //_addressController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    //_addressController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    userID = user!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userID);
    return await userRef.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator while waiting for the data
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Handle error
          return Text('Error: ${snapshot.error}');
        } else {
          // Data is available, build your UI
          // User? user = FirebaseAuth.instance.currentUser;
          return Scaffold(
            appBar: AppBar(
              leading: InkWell(
                child: const Icon(Icons.arrow_back_outlined),
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UserProfileTab(navBarIndex: 1)));
                },
              ),
              title: const Text(
                "Account Info",
                style: TextStyle(fontSize: 24),
              ),
              centerTitle: true,
            ),
            body: Consumer<UiProvider>(
              builder: (context, UiProvider notifier, child) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                "lib/assets/userImage.jpg",
                              ),
                              radius: 50,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              snapshot.data!['username'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField(
                              labelText: 'Username',
                              valueText: snapshot.data!['username'],
                              icon: Icons.person,
                              controller: _usernameController,
                              selectedfield: 'username',
                            ),
                            const SizedBox(height: 10),
                            _buildField(
                              labelText: 'Email',
                              valueText: snapshot.data!['email'],
                              icon: Icons.email,
                              controller: _emailController,
                              selectedfield: 'email',
                            ),
                            const SizedBox(height: 10),
                            _buildField(
                              labelText: 'Phone',
                              valueText: snapshot.data!['phone'],
                              icon: Icons.phone,
                              controller: _phoneController,
                              selectedfield: 'phone',
                            ),
                            const SizedBox(height: 10),
                            // _buildField(
                            //   labelText: 'Address',
                            //   valueText: snapshot.data!['address'],
                            //   icon: Icons.location_on,
                            //   controller: _addressController,
                            //   selectedfield: 'address',
                            // ),
                          ],
                        ),
                      ),
                      
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildField({
    required String labelText,
    required String valueText,
    required IconData icon,
    required TextEditingController controller,
    required String selectedfield,

  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            labelText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            valueText,
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Edit $labelText',
                style: TextStyle(
                  fontSize: 16,
                  ),
                ),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'New $labelText',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      // Update data in Firestore
                      // For example:
                      FirebaseFirestore.instance.collection('users').doc(userID).update({
                        '$selectedfield': controller.text,
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
