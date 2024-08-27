import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class ProviderFollowersTabContent extends StatefulWidget {
  ProviderFollowersTabContent({super.key});

  @override
  State<ProviderFollowersTabContent> createState() => _ProviderFollowersTabContentState();
}

class _ProviderFollowersTabContentState extends State<ProviderFollowersTabContent> {
  String? uid;

  List<Map<String,dynamic>>? followersPages=[];

  List<Map<String,dynamic>>? followersResult=[];

  List followers=[];

  Future<DocumentSnapshot> getUserData() async {
    User? prov = FirebaseAuth.instance.currentUser;
    String uid = prov!.uid;
    DocumentReference userRef =
    FirebaseFirestore.instance.collection('providers').doc(uid);
    this.uid = uid;
    DocumentSnapshot userDoc = await userRef.get();
    dynamic data = userDoc.data();
    followers = List.from(data['followers'] ?? []);
    followersPages=List.generate(followers.length, (index) => <String, dynamic>{});
    showFollowers();
    return userRef.get();
  }

  Future<void> showFollowers() async {
    try {
      // Retrieve brand document
      for(int i=0;i<followers.length;i++){
        DocumentSnapshot provSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(followers[i])
            .get();
        if (provSnap.exists) {
          // Access the data of the document
          Map<String, dynamic> data = provSnap.data() as Map<String, dynamic>;
          followersPages![i]["username"]= data['username'];
          print(followersPages);
          // Do something with the fieldValue
        } else {
          // Handle the case where the document doesn't exist
          print('Document does not exist');
        }
      }
      setState(() {
        followersResult=followersPages;
      });
    } catch (e) {
      print("Error: $e");
      // Handle error as needed
    }
  }

  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Your AllCategoriesScreen content goes here
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text("Followers List",style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: ListView.separated(
        itemCount: followersResult!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Color.fromRGBO(224, 224, 224, 1.0),
                  radius: 30,
                  child: Icon(
                    color: Color.fromRGBO(158, 158, 158, 1.0),
                    Icons.person,
                    size: 50,
                  )),
              title: Text(
                followersResult![index]["username"],
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Colors.white,
        ),
      ),
    );
  }
}
