// ignore_for_file: avoid_print, use_full_hex_values_for_flutter_colors, use_build_context_synchronously
import 'dart:typed_data';
import 'package:authentication/Screens/auth.dart';
import 'package:authentication/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ProviderSignUpContinueScreen extends StatefulWidget {
  const ProviderSignUpContinueScreen({super.key, required this.signUpCheck, required this.email, required this.password});
  final bool signUpCheck;
  final String email;
  final String password;

  @override
  State<ProviderSignUpContinueScreen> createState() => _ProviderSignUpContinueScreenState();
}

class _ProviderSignUpContinueScreenState extends State<ProviderSignUpContinueScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  // Text editing controllers
  final signupUsernameController = TextEditingController();
  final signupPhoneController = TextEditingController();
  String? signupPhoneErrorText;
  String? signupUsernameErrorText;
  Uint8List? image;
  bool imageInsertedOrNot = false;

  List<String> _selectedCategories = [];
  late List<String> _categories;
  List<String> times = ['Through 1 day', 'Through 2 day', 'Through 3 day', "Through 4 day", "Through 5 day", "Through 6 day", "Through a week"];
  String? selectedDeliveryTime;

  @override
  void initState() {
    super.initState();
    _selectedCategories = [];
    _categories = [];
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      final List<String> documentIds =
          querySnapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        _categories = documentIds; // Update the state with document IDs
      });
      print(_categories);
    } catch (e) {
      print('Error fetching document IDs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    MultiSelectDialogField<String> categoriesSelectField = MultiSelectDialogField(
      items: _categories.map((e) => MultiSelectItem<String>(e, e)).toList(),
      listType: MultiSelectListType.LIST,
      buttonText: const Text(
        "Select your categories",
        style: TextStyle(fontSize: 15),
      ),
      dialogHeight: 400,
      onConfirm: (values) {
        setState(() {
          _selectedCategories = values;
        });
      },
      chipDisplay: MultiSelectChipDisplay(
        onTap: (item) {
          setState(() {
            _selectedCategories.remove(item);
          });
        },
      ),
      onSelectionChanged: (selectedList) {
        setState(() {
          _selectedCategories = selectedList;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Continue Registration"),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 240,
              child: Image.asset("lib/assets/continue_register.jpeg"),
            ),
            const SizedBox(height: 10),
            // Login and Signup buttons
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Let's get started!",
                style: TextStyle(fontSize: 30),
              ),
            ),
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
                      errorText: signupUsernameErrorText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    keyboardType: TextInputType.phone, //To make the input only numbers
                    controller: signupPhoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      errorText: signupPhoneErrorText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // Circular border
                      border: Border.all(color: Colors.grey), // Optional: Add border color
                    ),
                    child: categoriesSelectField,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    //margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      value: selectedDeliveryTime,
                      icon: const Icon(Icons.arrow_downward_sharp),
                      iconSize: 24,
                      elevation: 12,
                      isExpanded: true,
                      underline: Container(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDeliveryTime = newValue;
                        });
                      },
                      items: times.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: const Text("Select Delivery Time"),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (imageInsertedOrNot == false)
                    MaterialButton(
                      minWidth: 200,
                      onPressed: () {
                        selectImage();
                      },
                      color: Colors.yellow[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                      ),
                      child: const Text(
                        "Insert your Logo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (imageInsertedOrNot == true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: MemoryImage(image!),
                        ),
                        const SizedBox(width: 13),
                        const Text(
                          "Logo inserted successfully",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Container(
                          width: 40, // Adjust the width as needed
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                imageInsertedOrNot = false;
                              });
                            },
                            icon: const Icon(
                              Icons.clear_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 300,
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
                          // Check username
                          if (signupUsernameController.text.isEmpty) {
                            signupUsernameErrorText = "Username is required";
                            hasError = true;
                          } else if (signupUsernameController.text.length < 4) {
                            signupUsernameErrorText = "Username must be at least 4 characters";
                            hasError = true;
                          } else {
                            signupUsernameErrorText = null;
                          }

                          // Check phone number
                          if (signupPhoneController.text.isEmpty) {
                            signupPhoneErrorText = "Phone number is required";
                            hasError = true;
                          } else {
                            signupPhoneErrorText = null;
                          }
                          if (selectedDeliveryTime == null && _selectedCategories.isEmpty) {
                            // Check selected delivery time
                            showToast(message: "Please select your categories & your delivery time");
                            hasError = true;
                          } else if (_selectedCategories.isEmpty && selectedDeliveryTime != null) {
                            // Check selected categories
                            showToast(message: "Please select your categories");
                            hasError = true;
                          } else if (selectedDeliveryTime == null && _selectedCategories.isNotEmpty) {
                            // Check selected delivery time
                            showToast(message: "Please select delivery time");
                            hasError = true;
                          }
                        });

                        if (!hasError) {
                          if (image != null) {
                            signUp();
                          } else {
                            showToast(message: "Please insert your logo");
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
            ),
          ],
        ),
      ),
    );
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String uniqueFilename = "$timestamp.jpg"; // Change the extension based on your needs

    Reference ref = storage.ref().child(childName).child(uniqueFilename);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadURL = await snapshot.ref.getDownloadURL();
    return downloadURL;
  }

  void selectImage() async {
    Uint8List img = await pickImageFromGallery(ImageSource.gallery);
    setState(() {
      image = img;
      imageInsertedOrNot = true;
    });
  }

  Future pickImageFromGallery(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      showToast(message: "Image inserted");
      return await file.readAsBytes();
    } else {
      showToast(message: "No image selected");
    }
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

      String imageURL = await uploadImageToStorage("ProvidersLogos", image!);
      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      
      String documentID = userCredential.user!.uid;
      // Store additional user data in Firestore
      await FirebaseFirestore.instance.collection('providers').doc(documentID).set({
        'email': widget.email,
        'password': widget.password,
        'phone': signupPhoneController.text,
        'categories': _selectedCategories,
        'deliveryTime': selectedDeliveryTime,
        'username': signupUsernameController.text,
        'LogoURL': imageURL,
        'followers':[],
      });

      if (mounted) {
        await pr.hide();
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Auth(role: "provider")));
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
}
