// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:authentication/Screens/Main%20Screens/welcome_screen.dart';
import 'package:authentication/Screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3), // Adjust the duration as needed
      () async {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // User is signed in
          // Determine user's role based on your implementation
          String role = await determineUserRole(user.uid);

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Auth(role: role)));
        } else {
          // User is not signed in
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomeScreen()));
        }
      },
    );
  }

  Future<String> determineUserRole(String userId) async {
    try {
      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
      CollectionReference providersCollection = FirebaseFirestore.instance.collection('providers');

      // Check if the user exists in the "users" collection
      var userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        return 'user';
      }

      // Check if the user exists in the "providers" collection
      var providerDoc = await providersCollection.doc(userId).get();
      if (providerDoc.exists) {
        return 'provider';
      }

      // If the user doesn't exist in either collection, return an appropriate value
      return 'unknown';
    } catch (e) {
      print('Error determining user role: $e');
      return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Image.asset(
            'lib/assets/splash_screen.png',
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
