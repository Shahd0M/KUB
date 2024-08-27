import 'package:authentication/Provider/provider.dart';
import 'package:authentication/Screens/Main%20Screens/welcome_screen.dart';
import 'package:authentication/Screens/User%20Screens/Following_List.dart';
import 'package:authentication/Screens/User%20Screens/account_info.dart';
import 'package:authentication/Screens/User%20Screens/user_cart.dart';
import 'package:authentication/Screens/User%20Screens/user_favourites.dart';
import 'package:authentication/Screens/User%20Screens/user_orders.dart';
import 'package:authentication/main.dart';
import 'package:authentication/widgets/user_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'about_app.dart';
import 'user_home_screen.dart';

class UserProfileTab extends StatefulWidget {
  final int navBarIndex;

  const UserProfileTab({Key? key, required this.navBarIndex});

  @override
  State<UserProfileTab> createState() => _UserProfileTabState();
}

class _UserProfileTabState extends State<UserProfileTab> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.navBarIndex;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      body: const UserProfileTabContent(), // Replace with your actual content
      bottomNavigationBar: UserBottomNavigationBarWrapper(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });

          // Handle navigation based on the index
          switch (index) {
            case 0:
              // Navigate to Home screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const UserHomeScreen(navBarIndex: 0)));
              //Navigator.pushReplacementNamed(context, '/userHome');
              break;
            case 1:
              // Navigate to Profile screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const UserProfileTab(navBarIndex: 1)));
              //Navigator.pushReplacementNamed(context, '/userProfile');
              break;
            case 2:
              // Navigate to Favorites screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const UserFavouritesTab(navBarIndex: 2)));
              //Navigator.pushReplacementNamed(context, '/userFavorites');
              break;
            case 3:
              // Navigate to Cart screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CartScreen(navBarIndex: 3)));
              //Navigator.pushReplacementNamed(context, '/userCart');
              break;
          }
        },
      ),
    );
  }
}


class UserProfileTabContent extends StatefulWidget {
  const UserProfileTabContent({Key? key});

  @override
  State<UserProfileTabContent> createState() => UserProfileTabContentState();
}

class UserProfileTabContentState extends State<UserProfileTabContent> {
  late Stream<DocumentSnapshot> userDataStream;

  Future<DocumentSnapshot> getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    return await userRef.get();
  }

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    String uid = user!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    userDataStream = userRef.snapshots();
  }

   @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<DocumentSnapshot>(
      stream: userDataStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Return a loading indicator while waiting for the data
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Handle error
          return Text('Error: ${snapshot.error}');
        } else {
          // Data is available, build your UI
          //User? user = FirebaseAuth.instance.currentUser;

          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Profile",
                style: TextStyle(fontSize: 24),
              ),
              centerTitle: true,
            ),
            body: Consumer<UiProvider>(
              builder: (context, UiProvider notifier, child) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "lib/assets/userImage.jpg",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                snapshot.data!['username'],
                                style: const TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AccountInfoScreen()));
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF0D0A35),
                                  size: 24,
                                ),
                                const SizedBox(width: 14),
                                const Text(
                                  "Account Info",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : const Color(0xFF0D0A35),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        FollowingListScreen()));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_add,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Following List",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const UserOrdersScreen()));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.assignment,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Your Orders",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AboutApp()));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "About App",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        InkWell(
                          onTap: () {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const aboutappScreen()));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.language,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Language",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                "English",
                                style: TextStyle(
                                    color: Color(0xFF7E7E7E), fontSize: 15),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        InkWell(
                          onTap: () {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const aboutappScreen()));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.dark_mode_sharp,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Dark Mode",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                activeColor: Colors.blue[400],
                                value: notifier.isDark,
                                onChanged: (value) => notifier.changeTheme(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        InkWell(
                          onTap: () {
                            FirebaseAuth.instance.signOut();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen()));
                            showToast(message: "User Signed Out");
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }
      },
    );
  }
}
