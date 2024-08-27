// ignore_for_file: avoid_print, use_full_hex_values_for_flutter_colors, use_build_context_synchronously

import 'package:authentication/Screens/Main%20Screens/forget_password.dart';
import 'package:authentication/Screens/Main%20Screens/images_slider.dart';
import 'package:authentication/Screens/Provider%20Screens/provider_register_continue.dart';
import 'package:authentication/Screens/auth.dart';
import 'package:authentication/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ProviderLoginAndSignUpScreen extends StatefulWidget {
  const ProviderLoginAndSignUpScreen({super.key, required this.signUpCheck});
  final bool signUpCheck;

  @override
  State<ProviderLoginAndSignUpScreen> createState() => _ProviderLoginAndSignUpScreenState();
}

class _ProviderLoginAndSignUpScreenState extends State<ProviderLoginAndSignUpScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  // Text editing controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();
  String? loginEmailErrorText;
  String? loginPasswordErrorText;
  String? signupEmailErrorText;
  String? signupPasswordErrorText;
  String? signupConfirmPasswordErrorText;
  bool showLoginContainer = true;
  bool showSignupContainer = false;

  final List<String> images = [
    'lib/assets/login.png',
    'lib/assets/login2.png',
    'lib/assets/login3.png',
  ];
  final List<String> textsForImages = [
    'All you want in one app',
    'Easy to pay by any way you want',
    'We make shopping easier',
  ];
  final List<Color> colorsForImages = [
    const Color(0xFF9DAFFB),
    Colors.white,
    Colors.white,
  ];
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize the state based on signUpCheck
    showLoginContainer = !widget.signUpCheck;
    showSignupContainer = widget.signUpCheck;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            CarouselWithDotsPage(imgList: images, textList: textsForImages, containerColors: colorsForImages),
            const SizedBox(height: 15),
            // Login and Signup buttons
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(13, 10, 53, 1.0),
                borderRadius: BorderRadius.circular(30),
              ),
              margin: const EdgeInsets.only(left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showLoginContainer = true; // Sets the login container to be visible
                          showSignupContainer = false; // Hides the signup container
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showLoginContainer // Background color changes based on container visibility
                            ? const Color(0xff0ffc632)
                            : const Color.fromRGBO(13, 10, 53, 1.0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 160,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showLoginContainer = false; // Hides the login container
                          showSignupContainer = true; // Sets the signup container to be visible
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showSignupContainer ? const Color(0xff0ffc632) : const Color.fromRGBO(13, 10, 53, 1.0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Signup'),
                    ),
                  ),
                ],
              ),
            ),

            // Conditional rendering for login and signup containers
            //law das login
            if (showLoginContainer)
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      // Text field for entering email
                      controller: loginEmailController,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          errorText: loginEmailErrorText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      // Text field for entering password
                      obscureText: true,
                      controller: loginPasswordController,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          errorText: loginPasswordErrorText),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Defines the action to perform on tapping forget password
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgetPassword(),
                              ),
                            );
                          },
                          child: Text(
                            // Text widget for displaying 'Forget Password'
                            'Forget Password',
                            style: TextStyle(
                              color: Colors.yellow[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            // law das signup
            if (showSignupContainer)
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(16), //Bnzbat shakl el signup
                child: Column(
                  children: [
                    TextField(
                      controller: signupEmailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        errorText: signupEmailErrorText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      controller: signupPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        errorText: signupPasswordErrorText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: true,
                      controller: signupConfirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        errorText: signupConfirmPasswordErrorText,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  // InkWell widget for adding onTap functionality
                  onTap: () async {
                    await signInWithGoogle(); // Call the signInWithGoogle function when tapped
                  }, //Defines the action to perform on tapping Google button
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        // Path to the Google image
                        "lib/assets/google_button.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 18,
                ),
                InkWell(
                  onTap: () {}, // Defines the action to perform on tapping Apple button
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset(
                        "lib/assets/apple_button.png",
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  height: 55,
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      bool hasError = false;
                      setState(() {
                        if (showSignupContainer) {
                          //check email
                          if (signupEmailController.text.isEmpty) {
                            signupEmailErrorText = "Email is required";
                            hasError = true;
                          } else if (!signupEmailController.text.contains("@")) {
                            signupEmailErrorText = "Email format is not valid";
                            hasError = true;
                          } else {
                            signupEmailErrorText = null;
                          }
                          //check password
                          if (signupPasswordController.text.isEmpty) {
                            signupPasswordErrorText = "Password is required";
                            hasError = true;
                          } else if (signupPasswordController.text.length < 6) {
                            signupPasswordErrorText = "Username must be at lease 6 characters";
                            hasError = true;
                          } else {
                            signupPasswordErrorText = null;
                          }
                          //check confirm password
                          if (signupConfirmPasswordController.text.isEmpty) {
                            signupConfirmPasswordErrorText = "Confirm Password is required";
                            hasError = true;
                          } else if (signupPasswordController.text != signupConfirmPasswordController.text && signupPasswordController.text.isNotEmpty && signupConfirmPasswordController.text.isNotEmpty) {
                            signupConfirmPasswordErrorText = "Passwords don't match!";
                            hasError = true;
                          } else {
                            signupConfirmPasswordErrorText = null;
                          }
                        } else if (showLoginContainer) {
                          //check email
                          if (loginEmailController.text.isEmpty) {
                            loginEmailErrorText = "Email is required";
                            hasError = true;
                          } else if (!loginEmailController.text.contains("@")) {
                            loginEmailErrorText = "Email format is not valid";
                            hasError = true;
                          } else {
                            loginEmailErrorText = null;
                          } //check password
                          if (loginPasswordController.text.isEmpty) {
                            loginPasswordErrorText = "Password is required";
                            hasError = true;
                          } else {
                            loginPasswordErrorText = null;
                          }
                        }
                      });
                      if (hasError == false) {
                        if (showSignupContainer) {
                          continueSignUp();
                        } else if (showLoginContainer) {
                          logIn();
                        }
                      }
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future continueSignUp() async {
    try {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProviderSignUpContinueScreen(signUpCheck: true, email: signupEmailController.text, password: signupPasswordController.text),
          ));
      showToast(message: "Please Continue Registration");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email is already in use.');
      } else {
        showToast(message: e.code);
      }
    }
  }

  Future logIn() async {
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(
      message: 'Signing In...',
      borderRadius: 35,
      backgroundColor: Colors.grey[350],
      progressWidget: const CircularProgressIndicator(
        strokeWidth: 5,
        // Adjust the size here
        valueColor: AlwaysStoppedAnimation<Color>(Colors.black), // Adjust the color as needed
      ),
      elevation: 20,
      insetAnimCurve: Curves.ease,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: const TextStyle(color: Colors.black, fontSize: 5, fontWeight: FontWeight.w400),
      messageTextStyle: const TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
    );
    try {
      await pr.show(); // Show the progress dialog
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: loginEmailController.text.trim(), password: loginPasswordController.text.trim());
      if (mounted) {
        await pr.hide();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Auth(role: 'provider')));
      }
      showToast(message: "User Logged in");
    } on FirebaseAuthException catch (e) {
      await pr.hide();
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password.');
      } else {
        showToast(message: e.code);
      }
    }
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
