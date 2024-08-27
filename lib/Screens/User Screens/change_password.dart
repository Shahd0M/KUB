// ignore_for_file: avoid_print, body_might_complete_normally_catch_error

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

var auth = FirebaseAuth.instance;
var currentUser = FirebaseAuth.instance.currentUser;

class _ChangePasswordState extends State<ChangePassword> {
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final oldPasswordController = TextEditingController();
  String? newPasswordErrorText;
  String? confirmPasswordErrorText;
  String? oldPasswordErrorText;
  String? emailErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "lib/assets/reset_password.jpg",
                fit: BoxFit.fitWidth,
                width: double.infinity,
                height: 280,
              ),
              const SizedBox(height: 20),
              const Text(
                "Change Your Password",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  errorText: emailErrorText,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                controller: oldPasswordController,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  errorText: oldPasswordErrorText,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  errorText: newPasswordErrorText,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  errorText: confirmPasswordErrorText,
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  //check email
                  if (emailController.text.isEmpty) {
                    setState(() {
                      emailErrorText = "Password is required";
                    });
                    return;
                  } else {
                    setState(() {
                      emailErrorText = null;
                    });
                  }
                  //check old password
                  if (oldPasswordController.text.isEmpty) {
                    setState(() {
                      oldPasswordErrorText = "Password is required";
                    });
                    return;
                  } else {
                    setState(() {
                      oldPasswordErrorText = null;
                    });
                  }
                  //check new password
                  if (newPasswordController.text.isEmpty) {
                    setState(() {
                      newPasswordErrorText = "Password is required";
                    });
                    return;
                  } else if (newPasswordController.text.length < 6) {
                    setState(() {
                      newPasswordErrorText = "Password must be at least 6 characters";
                    });
                    return;
                  } else {
                    setState(() {
                      newPasswordErrorText = null;
                    });
                  }
                  //check confirm password
                  if (confirmPasswordController.text.isEmpty) {
                    setState(() {
                      confirmPasswordErrorText = "Confirm Password is required";
                    });
                    return;
                  } else if (newPasswordController.text != confirmPasswordController.text && newPasswordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty) {
                    setState(() {
                      confirmPasswordErrorText = "Passwords don't match!";
                    });
                    return;
                  } else {
                    setState(() {
                      confirmPasswordErrorText = null;
                    });
                  }

                  // If no errors, proceed to change password
                  changePassword();
                },
                child: const Text(
                  "Change password",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changePassword() async {
    var cred = EmailAuthProvider.credential(email: emailController.text, password: oldPasswordController.text);
    await currentUser!
        .reauthenticateWithCredential(cred)
        .then(
          (value) => {
            currentUser!.updatePassword(newPasswordController.text),
          },
        )
        .catchError((error) {
      print(error.toString());
    });
  }
}
