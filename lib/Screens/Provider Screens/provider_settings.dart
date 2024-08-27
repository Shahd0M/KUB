import 'package:authentication/Screens/Main%20Screens/welcome_screen.dart';
import 'package:authentication/Screens/Provider%20Screens/provider_chats_screen.dart';
import 'package:authentication/Screens/Provider%20Screens/provider_followers_list.dart';
import 'package:authentication/Screens/Provider%20Screens/provider_home_screen.dart';
import 'package:authentication/Screens/Provider%20Screens/provider_orders_screen.dart';
import 'package:authentication/main.dart';
import 'package:authentication/widgets/provider_nav_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/provider.dart';
import '../User Screens/account_info.dart';
import '../User Screens/user_orders.dart';
import 'about_app.dart';

class ProviderSettingsTab extends StatefulWidget {
  final int navBarIndex;

  const ProviderSettingsTab({super.key, required this.navBarIndex});

  @override
  State<ProviderSettingsTab> createState() => ProviderSettingsTabState();
}

class ProviderSettingsTabState extends State<ProviderSettingsTab> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.navBarIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Settings"),
      ),
      bottomNavigationBar: ProviderBottomNavigationBarWrapper(
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
                      const ProviderHomeScreen(navBarIndex: 0)));
              //Navigator.pushReplacementNamed(context, '/userHome');
              break;
            case 1:
            // Navigate to Profile screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const ProviderChatsTab(navBarIndex: 1)));
              //Navigator.pushReplacementNamed(context, '/userProfile');
              break;
            case 2:
            // Navigate to Favorites screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const ProviderSettingsTab(navBarIndex: 2)));
              //Navigator.pushReplacementNamed(context, '/userFavorites');
              break;
            case 3:
            // Navigate to Cart screen
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                      const ProviderOrdersTab(navBarIndex: 3)));
              //Navigator.pushReplacementNamed(context, '/userCart');
              break;
          }
        },
      ),
      body:
      const ProviderSettingsTabContent(), // Replace with your actual content
    );
  }
}

class ProviderSettingsTabContent extends StatelessWidget {
  const ProviderSettingsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Your AllCategoriesScreen content goes here

    return Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<UiProvider>(
            builder: (context, UiProvider notifier, child) {
              return
                SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const SizedBox(height: 25),
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
                                "Account info",
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
                                        ProviderFollowersTabContent()));
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
                                "Followers List",
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
                                Icons.email,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),

                              const SizedBox(width: 14),
                              const Text(
                                "Change email",
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
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const gethelpsScreen()));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.password,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),

                              const SizedBox(width: 14),
                              const Text(
                                "Change Password",
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutApp()));
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
                                "About app",
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                "English",
                                style: TextStyle(
                                    color: Color(0xFF7E7E7E), fontSize: 17),
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
                                Icons.notifications,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),

                              const SizedBox(width: 14),
                              const Text(
                                "Notications",
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
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => const aboutappScreen()));
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.email,
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : const Color(0xFF0D0A35),
                                size: 24,
                              ),

                              const SizedBox(width: 14),
                              const Text(
                                "Dark mode",
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
                            showToast(message: "User signed out");
                          },
                          child: const Row(
                            children: [
                              
                              SizedBox(width: 14),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                  Icons.logout_rounded,
                                  color: Colors.black
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
            }),
    );
  }
}
