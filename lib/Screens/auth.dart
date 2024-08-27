import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'Main Screens/welcome_screen.dart';
import 'Provider Screens/provider_home_screen.dart';
import 'User Screens/user_home_screen.dart';

class Auth extends StatelessWidget {
  final String role;

  const Auth({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (role == "user") {
              final user = FirebaseAuth.instance.currentUser!;
              //print(user.uid);

              return FutureBuilder<List<String>>(
                future: getUsersIds(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<String> userIds = snapshot.data!;
                    if (userIds.contains(user.uid)) {
                      showToast(message: "User Logged in");
                      return const UserHomeScreen(navBarIndex: 0);
                    } else {
                      FirebaseAuth.instance.signOut();
                      showToast(message: "You selected to login as a user and entered provider credentials");
                      return const WelcomeScreen();
                    }
                  }
                },
              );
            } else if (role == "provider") {
              final user = FirebaseAuth.instance.currentUser!;
              // print(user.uid);

              return FutureBuilder<List<String>>(
                future: getProvidersIds(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<String> providersIds = snapshot.data!;
                    if (providersIds.contains(user.uid)) {
                      showToast(message: "Provider Logged in");
                      return const ProviderHomeScreen(navBarIndex: 0);
                    } else {
                      FirebaseAuth.instance.signOut();
                      showToast(message: "You selected to login as a provider and entered user credentials");
                      return const WelcomeScreen();
                    }
                  }
                },
              );
            }
          }

          // Add a default return statement to handle the case where none of the conditions are met
          return const WelcomeScreen();
        },
      ),
    );
  }

  Future<List<String>> getUsersIds() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('users').get();

    final List<String> userIds = querySnapshot.docs.map((doc) => doc.id).toList();

    return userIds;
  }

  Future<List<String>> getProvidersIds() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance.collection('providers').get();

    final List<String> providersIds = querySnapshot.docs.map((doc) => doc.id).toList();

    return providersIds;
  }
}
