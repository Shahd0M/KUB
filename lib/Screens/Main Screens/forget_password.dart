import 'package:authentication/Screens/Main%20Screens/otp.dart';
import 'package:authentication/Screens/Main%20Screens/welcome_screen.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

EmailOTP myauth = EmailOTP();

class _ForgetPasswordState extends State<ForgetPassword> {
  final emailController = TextEditingController();
  String? emailErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/forget_password.png', // Replace with your image asset path
                          height: 240, // Adjust the height of the image
                          width: 240, // Adjust the width of the image
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Forgot your password?",
                          style: TextStyle(fontSize: 35),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    Container(
                      margin: const EdgeInsets.only(left: 3),
                      child: const Text(
                        "Enter your information below or sign in with another account",
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefix: const Icon(Icons.email),
                          labelText: 'Email',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          errorText: emailErrorText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const WelcomeScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Register new account',
                          style: TextStyle(
                            color: Colors.yellow[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Container(
                      margin: const EdgeInsets.only(left: 20),
                      child: SizedBox(
                        height: 50,
                        width: 250,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            bool hasErrorr = false;
                            setState(() {
                              // Check email
                              if (emailController.text.isEmpty) {
                                emailErrorText = "Email is required";
                                hasErrorr = true;
                              } else if (!emailController.text.contains("@")) {
                                emailErrorText = "Email format is not valid";
                                hasErrorr = true;
                              } else {
                                emailErrorText = null;
                              }
                            });

                            if (hasErrorr == false) {
                              sendOTP();
                            } else {
                              print("Validation failed, hasErrorr is true");
                            }
                          },
                          child: const Text(
                            "Send",
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> sendOTP() async {
    myauth.setConfig(
      appEmail: "KUB@contact.com",
      appName: "KUB",
      userEmail: emailController.text,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );
    try {
      if (await myauth.sendOTP() == true) {
        showToast(message: "OTP Sent Successfully, Check your email");
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OTPScreen(email: emailController)));
      } else {
        showToast(message: "OTP Sent Failed, Enter valid email");
      }
    } on Exception catch (e) {
      print(e);
    }
  }
}
