import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';

class EditPostPage extends StatefulWidget {
  final Map<String, dynamic> postDetails;
  final String userID;
  final String postID;

  const EditPostPage({
    Key? key,
    required this.postDetails,
    required this.userID,
    required this.postID,
  }) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _itemImageController;
  late TextEditingController _itemNameController;
  late TextEditingController _itemDescriptionController;
  late TextEditingController _itemPriceController;
  late List<dynamic> _selectedColors;
  late List<dynamic> _selectedCategory;
  late List<dynamic> _selectedSize;
  late int _quantityCounter;

  List<String> _availableColors = [];
  List<String> _providerCategories = [];
  List<String> _subCategories = [];
  List<String> _sizes = [];

  


  @override
  void initState() {
    super.initState();
    _fetchUserCategories();
    _fetchColors();
    _fetchSizes();
    _itemImageController = TextEditingController(text: widget.postDetails['imageUrl']);
    _itemNameController = TextEditingController(text: widget.postDetails['itemName']);
    _itemDescriptionController = TextEditingController(text: widget.postDetails['itemDescription']);
    _itemPriceController = TextEditingController(text: widget.postDetails['itemPrice'].toString());
    _selectedColors = List<String>.from(widget.postDetails['selectedColors']);
    _selectedCategory = List<String>.from(widget.postDetails['selectedCategory']);
    _selectedSize = List<String>.from(widget.postDetails['selectedSize']);
    _quantityCounter = widget.postDetails['quantityCounter'];
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _itemPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('post id in edit page : ${widget.postID}');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(230, 222, 222, 100),
        title: Text('Edit Post'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _itemNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                    labelText: 'Item Name'
                ),

              // decoration: InputDecoration(labelText: 'Item Name'
              // , enabledBorder: ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _itemDescriptionController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Item Description'
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _itemPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Item Price'
              ),
            ),
            SizedBox(height: 20),
            _buildColorsSelectField(),
            SizedBox(height: 20),
            _buildCategorySelectField(),
            SizedBox(height: 20),
            _buildSizeSelectField(),
            SizedBox(height: 20),
            _buildQuantityCounter(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorsSelectField() {
    return MultiSelectDialogField(
      items: _availableColors.map((color) => MultiSelectItem<String>(color, color)).toList(),
      listType: MultiSelectListType.CHIP,
      buttonText: Text('Select Colors', style: TextStyle(
        color: Colors.white ,
        fontSize: 17,
          fontWeight: FontWeight.bold
      ),),
      decoration: BoxDecoration(
        color: Color.fromRGBO(20, 82, 133, 100),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color:Color.fromRGBO(20, 82, 133, 100)
            , width: 2.0),
        // No such attribute
      ),
      chipDisplay: MultiSelectChipDisplay(),
      initialValue: _selectedColors,
      onConfirm: (colors) {
        setState(() {
          _selectedColors = colors;
        });
      },
    );
  }

  Widget _buildCategorySelectField() {
    return MultiSelectDialogField(
      items: _subCategories.map((category) => MultiSelectItem<String>(category, category)).toList(),
      listType: MultiSelectListType.CHIP,
      buttonText: Text('Select Category', style: TextStyle(
          color: Colors.white ,
          fontSize: 17,
          fontWeight: FontWeight.bold
      ),),
      decoration: BoxDecoration(
        color: Color.fromRGBO(20, 82, 133, 100),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color:Color.fromRGBO(20, 82, 133, 100)
            , width: 2.0),
        // No such attribute
      ),
      chipDisplay: MultiSelectChipDisplay(),
      initialValue: _selectedCategory,
      onConfirm: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
    );
  }
  Widget _buildSizeSelectField() {
    return MultiSelectDialogField(
      items: _sizes.map((size) => MultiSelectItem<String>(size, size)).toList(),
      listType: MultiSelectListType.CHIP,
      buttonText: Text('Select Size', style: TextStyle(
          color: Colors.white ,
          fontSize: 17,
        fontWeight: FontWeight.bold
      ),),
      decoration: BoxDecoration(
        color: Color.fromRGBO(20, 82, 133, 100),
        borderRadius: BorderRadius.all(Radius.circular(5)),
        border: Border.all(color:Color.fromRGBO(20, 82, 133, 100)
            , width: 2.0),
        // No such attribute
      ),
      chipDisplay: MultiSelectChipDisplay(),
      initialValue: _selectedSize,
      onConfirm: (size) {
        setState(() {
          _selectedSize = size;
        });
      },
    );
  }

  Widget _buildQuantityCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.remove ,
            color: Colors.red,
            size: 25,
          ),
          onPressed: () {
            setState(() {
              if (_quantityCounter > 1) {
                _quantityCounter--;
              }
            });
          },
        ),
        Text('$_quantityCounter'),
        IconButton(
          icon: Icon(Icons.add ,
            color: Colors.red,
            size: 25,
          ),
          onPressed: () {
            setState(() {
              _quantityCounter++;
            });
          },
        ),
      ],
    );
  }

  void _saveChanges() async {
    try {
      // Construct updated post data
      Map<String, dynamic> updatedPostData = {
        'imageUrl': _itemImageController.text,
        'itemName': _itemNameController.text,
        'itemDescription': _itemDescriptionController.text,
        'itemPrice': double.parse(_itemPriceController.text),
        'selectedColors': _selectedColors,
        'selectedCategory': _selectedCategory,
        'selectedSize': _selectedSize,
        'quantityCounter': _quantityCounter,
      };

      // Get a reference to the post document
      DocumentReference<Map<String, dynamic>> postRef =
          FirebaseFirestore.instance.collection('providers').doc(widget.userID).collection('posts').doc(widget.postID);

      // Update the post document with the new data
      await postRef.update(updatedPostData);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes saved successfully'),
        ),
      );

      // Navigate back to the post details page
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      print('Error saving changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes'),
        ),
      );
    }
  }


  Future<void> _fetchUserCategories() async {
    try {
      // Get the current user ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch the provider document for the current user
      DocumentSnapshot<Map<String, dynamic>> providerSnapshot =
      await FirebaseFirestore.instance.collection('providers').doc(userId).get();

      // Check if the provider document exists and contains the 'categories' field
      if (providerSnapshot.exists && providerSnapshot.data()!.containsKey('categories')) {
        // Access the categories array in the provider document
        List<dynamic> categoriesArray = providerSnapshot.data()!['categories'];
        print('this is categories array : $categoriesArray');
        setState(() {
          _providerCategories = categoriesArray.map((color) => color.toString()).toList();
        });
        print(_providerCategories);

        _fetchCategoriesForProvider(_providerCategories);
      } else {
        print("Provider document does not exist or does not contain 'categories' field");
      }
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching user categories: $e');
    }
  }

  Future<void> _fetchCategoriesForProvider(List<String> providerCategories) async {
    try {
      List<String> subCategories = [];

      // Loop through each category ID in the providerCategories list
      for (var categoryId in providerCategories) {
        // Fetch documents from the 'categories' collection that match the category ID
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('categories')
            .where(FieldPath.documentId, isEqualTo: categoryId)
            .get();

        // Loop through the documents in the snapshot
        snapshot.docs.forEach((doc) {
          // Extract the 'subCategories' field from each document and add it to the subCategories list
          if (doc.data().containsKey('subCategories')) {
            subCategories.addAll(List<String>.from(doc.data()['subCategories']));
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
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('productColors').doc('productColors').get();

      // Access the subCategories array in each document
      List<dynamic> colorsArray = snapshot.data()!['colors'];

      // Convert the colors array to a list of strings
      List<String> availableColors = colorsArray.map((color) => color.toString()).toList();

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
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('productSizes').doc('productSizes').get();

      // Access the subCategories array in each document
      List<dynamic> sizesArray = snapshot.data()!['sizes'];

      // Convert the colors array to a list of strings
      List<String> sizes = sizesArray.map((size) => size.toString()).toList();

      // Update the state with the fetched subcategories
      setState(() {
        _sizes = sizes;
      });
    } catch (e) {
      // Handle any errors that occur during fetching
      print('Error fetching subcategories: $e');
    }
  }

}
