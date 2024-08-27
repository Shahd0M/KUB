// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:async';

import 'package:authentication/Screens/Main%20Screens/forget_password.dart';
import 'package:authentication/Screens/User%20Screens/user_login_and_signup.dart';
import 'package:authentication/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key, required this.email});
  final TextEditingController email;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late Timer _timer;
  late StreamController<int> _timerController;
  int _secondsRemaining = 120; // Initial duration for the timer
  late bool _isResendEnabled;
  final pinController1 = TextEditingController();
  final pinController2 = TextEditingController();
  final pinController3 = TextEditingController();
  final pinController4 = TextEditingController();
  final pinController5 = TextEditingController();
  final pinController6 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timerController = StreamController<int>();
    _isResendEnabled = false;
    _startTimer(); // Initialize pinFields
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
        _timerController.add(_secondsRemaining);
      } else {
        // Stop the timer when it reaches 0
        _timer.cancel();
        setState(() {
          _isResendEnabled = true; // Enable resend when the timer is 0
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerController.close();
    super.dispose();
  }

  void sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } catch (e) {
      print('Error sending password reset email: $e');
    }
  }

  void verifyOTP() async {
    String userOTP = pinController1.text + pinController2.text + pinController3.text + pinController4.text + pinController5.text + pinController6.text;
    print(userOTP);
    if (await myauth.verifyOTP(otp: userOTP) == true) {
      showToast(message: "OTP verified!, Reset password form sent to your email!");
      sendPasswordResetEmail(widget.email.text);
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserLoginAndSignUpScreen(signUpCheck: false)));
    } else {
      showToast(message: "Invalid OTP!");
    }
    // Your verification logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "Verify Your Email",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "OTP has been sent to",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.email.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                margin: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 60,
                      width: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[400],
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.length == 1) {
                            // Concatenate the entered digits to userOTP when the last digit is entered
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: pinController1,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[400],
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.length == 1) {
                            // Concatenate the entered digits to userOTP when the last digit is entered
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: pinController2,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[400],
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.length == 1) {
                            // Concatenate the entered digits to userOTP when the last digit is entered
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: pinController3,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[400],
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.length == 1) {
                            // Concatenate the entered digits to userOTP when the last digit is entered
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: pinController4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[400],
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.length == 1) {
                            // Concatenate the entered digits to userOTP when the last digit is entered
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: pinController5,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 45,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey[400],
                      ),
                      child: TextFormField(
                        onChanged: (value) {
                          if (value.length == 1) {
                            // Concatenate the entered digits to userOTP when the last digit is entered
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(1),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        controller: pinController6,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<int>(
                    stream: _timerController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        int secondsRemaining = snapshot.data ?? 0;
                        int minutes = (secondsRemaining ~/ 60);
                        int seconds = secondsRemaining % 60;
                        String formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                        return Row(
                          children: [
                            Text(
                              formattedTime,
                              style: const TextStyle(fontSize: 25),
                            ),
                          ],
                        );
                      } else {
                        return Container(); // Placeholder widget, replace with your UI logic
                      }
                    },
                  ),
                  const SizedBox(width: 40),
                  ResendButton(
                    isEnabled: _isResendEnabled,
                    onTap: () {
                      // Defines the action to perform on tapping resend
                      // This will be executed only when _isResendEnabled is true
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: verifyOTP,
                child: const Text(
                  "Verify OTP",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResendButton extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const ResendButton({super.key, required this.isEnabled, required this.onTap});

  @override
  ResendButtonState createState() => ResendButtonState();
}

class ResendButtonState extends State<ResendButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onTap : null,
      child: Text(
        'Resend OTP',
        style: TextStyle(
          color: widget.isEnabled ? Colors.yellow[600] : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 25,
        ),
      ),
    );
  }
}
