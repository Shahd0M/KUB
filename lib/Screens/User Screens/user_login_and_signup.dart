// ignore_for_file: avoid_print, use_full_hex_values_for_flutter_colors, use_build_context_synchronously
import 'package:authentication/Screens/Main%20Screens/current_location.dart';
import 'package:authentication/Screens/Main%20Screens/forget_password.dart';
import 'package:authentication/Screens/Main%20Screens/images_slider.dart';
import 'package:authentication/Screens/auth.dart';
import 'package:authentication/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class UserLoginAndSignUpScreen extends StatefulWidget {
  const UserLoginAndSignUpScreen({super.key, required this.signUpCheck});
  final bool signUpCheck;

  @override
  State<UserLoginAndSignUpScreen> createState() =>
      _UserLoginAndSignUpScreenState();
}

class _UserLoginAndSignUpScreenState extends State<UserLoginAndSignUpScreen> {

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  // Text editing controllers
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final signupUsernameController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPhoneController = TextEditingController();
  final signupAddressController = TextEditingController();
  final signupBuildingnameController = TextEditingController();
  final signupFloorController = TextEditingController();
  final signupFlatController = TextEditingController();
  String? loginEmailErrorText;
  String? loginPasswordErrorText;
  String? signupUsernameErrorText;
  String? signupPasswordErrorText;
  String? signupConfirmPasswordErrorText;
  String? signupEmailErrorText;
  String? signupPhoneErrorText;
  String? signupAddressErrorText;
  String? signupBuildingnameErrorText;
  String? signupFloorErrorText;
  String? signupFlatErrorText;
  bool showLoginContainer = true;
  bool showSignupContainer = false;
  bool addressConfirmed = false;

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

  List<Map<String, String>> addresses = [];
  final _formKey = GlobalKey<FormState>();

  void _addAddress() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        addresses.add({
          'Address': signupAddressController.text,
          'Building Num': signupBuildingnameController.text,
          'Floor': signupFloorController.text,
          'Flat': signupFlatController.text,
        });
      });
      _formKey.currentState!.reset();
    }
  }

  int currentImageIndex = 0;

  @override
  void dispose() {
    signupEmailController.dispose();
    signupPasswordController.dispose();
    super.dispose();
  }

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
            CarouselWithDotsPage(
                imgList: images,
                textList: textsForImages,
                containerColors: colorsForImages),
            const SizedBox(height: 10),
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
                          showLoginContainer =
                          true; // Sets the login container to be visible
                          showSignupContainer =
                          false; // Hides the signup container
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        showLoginContainer // Background color changes based on container visibility
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
                          showLoginContainer =
                          false; // Hides the login container
                          showSignupContainer =
                          true; // Sets the signup container to be visible
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showSignupContainer
                            ? const Color(0xff0ffc632)
                            : const Color.fromRGBO(13, 10, 53, 1.0),
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
            const SizedBox(height: 30),
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
                            Navigator.pushReplacement(
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
                      controller: signupUsernameController,
                      decoration: InputDecoration(
                          labelText: 'Username',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          errorText: signupUsernameErrorText),
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
                          errorText: signupPasswordErrorText),
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
                          errorText: signupConfirmPasswordErrorText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: signupEmailController,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          errorText: signupEmailErrorText),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType:
                      TextInputType.phone, //To make the input only numbers
                      controller: signupPhoneController,
                      decoration: InputDecoration(
                          labelText: 'Phone',
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          errorText: signupPhoneErrorText),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextField(
                            controller: signupAddressController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              errorText: signupAddressErrorText,
                              suffixIcon: InkWell(
                                onTap: () async {
                                  // Navigate to the CurrentLocation page and get the confirmed address
                                  String? confirmedAddress = await showDialog<String>(
                                    context: context,
                                    builder: (context) => const CurrentLocation(),
                                  );

                                  // Update the text field and set confirmation status
                                  if (confirmedAddress != null) {
                                    signupAddressController.text = confirmedAddress;
                                    setState(() {
                                      addressConfirmed = true;
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!addressConfirmed) // Show text conditionally
                                      const Text(
                                        'Current Location',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(255, 211, 197, 75),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 35,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: signupBuildingnameController,
                            decoration: InputDecoration(
                                labelText: 'Building name',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                errorText: signupBuildingnameErrorText),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            keyboardType:
                            TextInputType.phone, //To make the input only numbers
                            controller: signupFloorController,
                            decoration: InputDecoration(
                                labelText: 'Floor #',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                errorText: signupFloorErrorText),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            keyboardType:
                            TextInputType.phone, //To make the input only numbers
                            controller: signupFlatController,
                            decoration: InputDecoration(
                                labelText: 'Flat #',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                errorText: signupFlatErrorText),
                          ),
                        ],
                      ),

                    )


                  ],
                ),
              ),
            const SizedBox(height: 16),
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
                  onTap:
                      () {}, // Defines the action to perform on tapping Apple button
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
                const SizedBox(
                  //Empty space
                  width: 18,
                ),
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
                          //check username
                          if (signupUsernameController.text.isEmpty) {
                            signupUsernameErrorText = "Username is required";
                            hasError = true;
                          } else if (signupUsernameController.text.length < 4) {
                            signupUsernameErrorText =
                            "Username must be at lease 4 characters";
                            hasError = true;
                          } else {
                            signupUsernameErrorText = null;
                          }
                          //check password
                          if (signupPasswordController.text.isEmpty) {
                            signupPasswordErrorText = "Password is required";
                            hasError = true;
                          } else if (signupPasswordController.text.length < 6) {
                            signupPasswordErrorText =
                            "Username must be at lease 6 characters";
                            hasError = true;
                          } else {
                            signupPasswordErrorText = null;
                          }
                          //check confirm password
                          if (signupConfirmPasswordController.text.isEmpty) {
                            signupConfirmPasswordErrorText =
                            "Confirm Password is required";
                            hasError = true;
                          } else if (signupPasswordController.text !=
                              signupConfirmPasswordController.text &&
                              signupPasswordController.text.isNotEmpty &&
                              signupConfirmPasswordController.text.isNotEmpty) {
                            signupConfirmPasswordErrorText =
                            "Passwords don't match!";
                            hasError = true;
                          } else {
                            signupConfirmPasswordErrorText = null;
                          } //check email
                          if (signupEmailController.text.isEmpty) {
                            signupEmailErrorText = "Email is required";
                            hasError = true;
                          } else if (!signupEmailController.text
                              .contains("@")) {
                            signupEmailErrorText = "Email format is not valid";
                            hasError = true;
                          } else {
                            signupEmailErrorText = null;
                          }
                          //check phone number
                          if (signupPhoneController.text.isEmpty) {
                            signupPhoneErrorText = "Phone number is required";
                            hasError = true;
                          } else {
                            signupPhoneErrorText = null;
                          }
                         // check address
                          if (signupAddressController.text.isEmpty) {
                            signupAddressErrorText = "Address is required";
                            hasError = true;
                          } else {
                            signupAddressErrorText = null;
                          }
                          if (signupBuildingnameController.text.isEmpty) {
                            signupBuildingnameErrorText = "Building name or number is required";
                            hasError = true;
                          } else {
                            signupBuildingnameErrorText = null;
                          }
                          if (signupFloorController.text.isEmpty) {
                            signupFloorErrorText = "Floor number is required";
                            hasError = true;
                          } else {
                            signupFloorErrorText = null;
                          }
                          if (signupFlatController.text.isEmpty) {
                            signupFlatErrorText = "Flat number is required";
                            hasError = true;
                          } else {
                            signupFlatErrorText = null;
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
                          signUp();
                          _addAddress();

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

  Future signUp() async {
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(
      message: 'Signing Up...',
      borderRadius: 35,
      backgroundColor: Colors.grey[350],
      progressWidget: const CircularProgressIndicator(
        strokeWidth: 5,
        // Adjust the size here
        valueColor: AlwaysStoppedAnimation<Color>(
            Colors.black), // Adjust the color as needed
      ),
      elevation: 20,
      insetAnimCurve: Curves.ease,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: const TextStyle(
          color: Colors.black, fontSize: 5, fontWeight: FontWeight.w400),
      messageTextStyle: const TextStyle(
          color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
    );

    try {
      await pr.show(); // Show the progress dialog

      // Create user in Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: signupEmailController.text.trim(),
        password: signupPasswordController.text.trim(),
      );

      // Store additional user data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'email': signupEmailController.text.trim(),
        'password': signupPasswordController.text.trim(),
        'username': signupUsernameController.text.trim(),
        'phone': signupPhoneController.text.trim(),
        'following':[],
        'cards' :[],
      },
      );
      //
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid) // Use the actual user ID
          .set({
        'addresses': addresses ,
      }, SetOptions(merge: true));

        if (mounted) {
        await pr.hide();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Auth(role: 'user')));
      }

      showToast(message: "User Signed up");
    } on FirebaseAuthException catch (e) {
      await pr.hide();
      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
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
        valueColor: AlwaysStoppedAnimation<Color>(
            Colors.black), // Adjust the color as needed
      ),
      elevation: 20,
      insetAnimCurve: Curves.ease,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: const TextStyle(
          color: Colors.black, fontSize: 5, fontWeight: FontWeight.w400),
      messageTextStyle: const TextStyle(
          color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
    );
    try {
      await pr.show(); // Show the progress dialog
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: loginEmailController.text.trim(),
          password: loginPasswordController.text.trim());
      if (mounted) {
        await pr.hide();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const Auth(role: 'user')));
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
