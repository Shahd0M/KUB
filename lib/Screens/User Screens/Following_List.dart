import 'package:authentication/Screens/User%20Screens/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FollowingListScreen extends StatefulWidget {

  @override
  State<FollowingListScreen> createState() => _FollowingListScreenState();
}

class _FollowingListScreenState extends State<FollowingListScreen> {

  String? uid;
  List<Map<String,dynamic>>? followingPages=[];
  List<Map<String,dynamic>>? followingResult=[];
  List following=[];

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(uid);
    this.uid = uid;
    DocumentSnapshot userDoc = await userRef.get();
    dynamic data = userDoc.data();
    following = List.from(data['following'] ?? []);
    followingPages=List.generate(following.length, (index) => <String, dynamic>{});
    showFollowing();
    return userRef.get();
  }

  Future<void> showFollowing() async {
    try {
      // Retrieve brand document
      for(int i=0;i<following.length;i++){
        DocumentSnapshot provSnap = await FirebaseFirestore.instance
            .collection('providers')
            .doc(following[i])
            .get();
         if (provSnap.exists) {
           // Access the data of the document
           Map<String, dynamic> data = provSnap.data() as Map<String, dynamic>;
             followingPages![i]["username"]= data['username'];
             followingPages![i]["LogoURL"]= data['LogoURL'];
           print(followingPages);
           // Do something with the fieldValue
         } else {
           // Handle the case where the document doesn't exist
           print('Document does not exist');
         }
      }
      setState(() {
        followingResult=followingPages;
      });
    } catch (e) {
      print("Error: $e");
      // Handle error as needed
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UserProfileTab(navBarIndex: 1,)));
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Following List ',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        elevation: 0.0,
      ),
      body:followingResult!.isNotEmpty?ListView.separated(
        itemCount: followingResult!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15, top: 20),
            // padding: const EdgeInsets.only(left: 15.0, right: 15, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: SizedBox.fromSize(
                    size: const Size.fromRadius(40), // Image radius
                    child: Image(image: NetworkImage(followingResult![index]["LogoURL"]), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      followingResult![index]["username"],
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 21,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white,
        ),
      ):Center(
        child: Container(
          child: const Text(
            "No Result Found",
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.red),
          ),
        ),
      )
    );
  }
}