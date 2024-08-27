import 'dart:typed_data';
import 'package:authentication/Screens/Provider%20Screens/provider_home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import '../../main.dart';

class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  AddItemState createState() => AddItemState();
}

class AddItemState extends State<AddItem> {
  Uint8List? image;
  bool imageInsertedOrNot = false;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final itemName = TextEditingController();
  String? itemNameErrorText;
  final itemDescription = TextEditingController();
  String? itemDescriptionErrorText;
  final itemPrice = TextEditingController();
  String? itemPriceErrorText;

  List<String> _selectedCategory = [];
  List<String> _selectedColors = [];
  List<String> _selectedSize = [];

  List<String> _providerCategories = [];
  List<String> _subCategories = [];

  List<String> _availableColors = [];
  int quantityCounter = 1;

  @override
  void initState() {
    super.initState();
    _fetchUserCategories();
    _fetchColors();
    _fetchSizes();
  }

  Future<void> _fetchUserCategories() async {
    try {
      // Get the current user ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the provider document for the current user
      DocumentSnapshot<Map<String, dynamic>> providerSnapshot =
          await FirebaseFirestore.instance
              .collection('providers')
              .doc(userId)
              .get();

      // Check if the provider document exists and contains the 'categories' field
      if (providerSnapshot.exists &&
          providerSnapshot.data()!.containsKey('categories')) {
        // Access the categories array in the provider document
        List<dynamic> categoriesArray = providerSnapshot.data()!['categories'];
        print('this is categories array : $categoriesArray');
        setState(() {
          _providerCategories =
              categoriesArray.map((color) => color.toString()).toList();
        });
        print(_providerCategories);

        _fetchCategoriesForProvider(_providerCategories);
      } else {
        print(
            "Provider document does not exist or does not contain 'categories' field");
      }
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching user categories: $e');
    }
  }

  Future<void> _fetchCategoriesForProvider(
      List<String> providerCategories) async {
    try {
      List<String> subCategories = [];

      // Loop through each category ID in the providerCategories list
      for (var categoryId in providerCategories) {
        // Fetch documents from the 'categories' collection that match the category ID
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('categories')
            .where(FieldPath.documentId, isEqualTo: categoryId)
            .get();

        // Loop through the documents in the snapshot
        snapshot.docs.forEach((doc) {
          // Extract the 'subCategories' field from each document and add it to the subCategories list
          if (doc.data().containsKey('subCategories')) {
            subCategories
                .addAll(List<String>.from(doc.data()['subCategories']));
          }
        });
      }
      print('subcategories : $subCategories');

      // Save the fetched subcategories in _subCategories list
      setState(() {
        _subCategories = subCategories;
      });
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching categories for provider: $e');
    }
  }

  Future<void> _fetchColors() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('productColors')
          .doc('productColors')
          .get();

      // Access the subCategories array in each document
      List<dynamic> colorsArray = snapshot.data()!['colors'];

      // Convert the colors array to a list of strings
      List<String> availableColors =
          colorsArray.map((color) => color.toString()).toList();

      // Update the state with the fetched subcategories
      setState(() {
        _availableColors = availableColors;
      });
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching subcategories: $e');
    }
  }

  Future<void> _fetchSizes() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('productSizes')
          .doc('productSizes')
          .get();

      // Access the subCategories array in each document
      List<dynamic> sizesArray = snapshot.data()!['sizes'];

      // Convert the colors array to a list of strings
      List<String> availableSizes =
          sizesArray.map((size) => size.toString()).toList();

      // Update the state with the fetched subcategories
      setState(() {
        _selectedSize = availableSizes;
      });
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching subcategories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    MultiSelectDialogField<String> categorySelectField = MultiSelectDialogField(
      items: _subCategories.map((e) => MultiSelectItem<String>(e, e)).toList(),
      listType: MultiSelectListType.LIST,
      buttonText: const Text(
        "Category",
        style: TextStyle(fontSize: 17),
      ),
      dialogHeight: 400,
      onConfirm: (values) {
        setState(() {
          _subCategories = values;
        });
      },
      chipDisplay: MultiSelectChipDisplay(
        chipColor: Colors.green,
        textStyle: const TextStyle(color: Colors.black),
        onTap: (item) {
          setState(() {
            _selectedCategory.remove(item);
          });
        },
      ),
      onSelectionChanged: (selectedList) {
        setState(() {
          _selectedCategory = selectedList;
        });
      },
    );

    MultiSelectDialogField<String> colorsSelectField = MultiSelectDialogField(
      items:
          _availableColors.map((e) => MultiSelectItem<String>(e, e)).toList(),
      listType: MultiSelectListType.LIST,
      backgroundColor: Colors.grey[200],
      buttonText: const Text(
        "Colors",
        style: TextStyle(fontSize: 17),
      ),
      dialogHeight: 400,
      onConfirm: (values) {
        setState(() {
          _selectedColors = values;
        });
      },
      chipDisplay: MultiSelectChipDisplay(
        chipColor: Colors.green,
        textStyle: const TextStyle(color: Colors.black),
        onTap: (item) {
          setState(() {
            _selectedColors.remove(item);
          });
        },
      ),
      onSelectionChanged: (selectedList) {
        setState(() {
          _selectedColors = selectedList;
        });
      },
    );

    MultiSelectDialogField<String> sizesSelectField = MultiSelectDialogField(
      items: _selectedSize.map((e) => MultiSelectItem<String>(e, e)).toList(),
      listType: MultiSelectListType.LIST,
      backgroundColor: Colors.grey[200],
      buttonText: const Text(
        "Sizes",
        style: TextStyle(fontSize: 17),
      ),
      dialogHeight: 400,
      onConfirm: (values) {
        setState(() {
          _selectedSize = values;
        });
      },
      chipDisplay: MultiSelectChipDisplay(
        chipColor: Colors.green,
        textStyle: const TextStyle(color: Colors.black),
        onTap: (item) {
          setState(() {
            _selectedSize.remove(item);
          });
        },
      ),
      onSelectionChanged: (selectedList) {
        setState(() {
          _selectedSize = selectedList;
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          child: const Icon(Icons.arrow_back_outlined,
              size: 25, color: Colors.black),
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProviderHomeScreen(
                          navBarIndex: 0,
                        )));
          },
        ),
        title: const Text(
          'New Item',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageInsertedOrNot == false)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: GestureDetector(
                          onTap: () {
                            selectImage();
                          },
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            // Add padding around the container
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Make the container circular
                              color: const Color.fromRGBO(
                                  255, 198, 50, 1), // Choose a background color
                            ),
                            child: Icon(
                              Icons.add_a_photo, // Use the "add photo" icon
                              size: 40, // Adjust the size of the icon as needed
                              color: Colors.white, // Set the color of the icon
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                if (imageInsertedOrNot == true)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 280,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: image != null
                                  ? DecorationImage(
                                      image: MemoryImage(image!),
                                      fit: BoxFit.cover,
                                    )
                                  : null, // Set image to null if it is null
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(255, 198, 50, 1),
                                shape: BoxShape.circle,
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
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: itemName,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    errorText: itemNameErrorText,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: itemDescription,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Write a Description for the product..',
                    errorText: itemDescriptionErrorText,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  child: categorySelectField,
                ),
                const SizedBox(height: 20),
                Container(
                  child: colorsSelectField,
                ),
                const SizedBox(height: 20),
                Container(
                  child: sizesSelectField,
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.phone,
                  //To make the input only numbers
                  controller: itemPrice,
                  decoration: InputDecoration(
                    labelText: 'Price L.E',
                    prefixIcon: const Icon(Icons.attach_money),
                    errorText: itemPriceErrorText,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Quantity",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          quantityCounter -= 1;
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '$quantityCounter',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantityCounter += 1;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      width: 240,
                      child: ElevatedButton(
                        onPressed: () {
                          bool hasError = false;
                          setState(() {
                            if (itemName.text.isEmpty) {
                              itemNameErrorText = "Item name is required";
                              hasError = true;
                            } else {
                              itemNameErrorText = null;
                            }
                            if (itemDescription.text.isEmpty) {
                              itemDescriptionErrorText =
                                  "ItemDescription is required";
                              hasError = true;
                            } else {
                              itemDescriptionErrorText = null;
                            }
                            if (_selectedColors.isEmpty &&
                                _selectedCategory.isEmpty) {
                              showToast(
                                  message:
                                      "Please select a Category and color");
                              hasError = true;
                            } else if (_selectedColors.isEmpty &&
                                _selectedCategory.isNotEmpty) {
                              // Check selected colors
                              showToast(
                                  message: "Please select available colors");
                              hasError = true;
                            } else if (_selectedColors.isNotEmpty &&
                                _selectedCategory.isEmpty) {
                              showToast(message: "Please select a Category");
                              hasError = true;
                            }
                          });
                          if (itemPrice.text.isEmpty) {
                            itemPriceErrorText = "Phone number is required";
                            hasError = true;
                          } else {
                            itemPriceErrorText = null;
                          }

                          if (!hasError) {
                            if (image != null) {
                              addPostToProvider();
                            } else {
                              showToast(message: "Please insert Product image");
                            }
                          }

                          // Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                        ),
                        child: const Text(
                          'Post',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> addPostToProvider() async {
    try {
      String imageUrl = await uploadImageToStorage('posts', image!);

      // Get the current user (provider)
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated.");
      }

      // Get the UID of the provider
      String providerUid = user.uid;

      // Construct the post data
      Map<String, dynamic> postData = {
        'itemName': itemName.text,
        'itemDescription': itemDescription.text,
        'itemPrice': double.parse(itemPrice.text),
        'imageUrl': imageUrl,
        'selectedColors': _selectedColors,
        'selectedCategory': _selectedCategory,
        'selectedSize': _selectedSize,
        'quantityCounter': quantityCounter,
      };

      //Get a reference to the provider's document
      // DocumentReference providerRef = FirebaseFirestore.instance
      //     .collection('providers')
      //     .doc(providerUid)
      //     .collection('posts')
      //     .doc();
      //
      // print(providerRef);
      // Get a reference to the provider's "posts" subcollection
      CollectionReference postsRef = FirebaseFirestore.instance
          .collection('providers')
          .doc(providerUid)
          .collection('posts');

      // Add the post data to the "posts" subcollection
      await postsRef.add(postData);

      // Add the post data to the provider's posts list
      // await providerRef.update({
      //   'posts': FieldValue.arrayUnion([postData])
      // });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ProviderHomeScreen(navBarIndex: 0),
        ),
      );
      showToast(message: "Post added successfully");
      print("Post added successfully.");
    } catch (e) {
      print("Error adding post: $e");
      // Handle errors here
    }
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String uniqueFilename =
        "$timestamp.jpg"; // Change the extension based on your needs

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
}
