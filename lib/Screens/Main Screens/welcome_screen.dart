import 'package:authentication/Screens/Provider%20Screens/provider_register_and_login.dart';
import 'package:authentication/Screens/User%20Screens/user_login_and_signup.dart';
import 'package:authentication/widgets/choose_role_login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Boolean variables to track the state of each icon
  bool _is1stIconChanged = false;
  bool _is2ndIconChanged = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Stack(
              //To allow multiple widgets to be stacked on top of each other
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    "lib/assets/1st page.png", //Specifies the path to the image asset.
                    fit: BoxFit.fitWidth, //makes the image fill the width of the container
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 200,
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            // To display a text widget
                            "WELCOME To KUB",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ), // Text style with its colour and size
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          const Text(
                            "Join as a user or provider",
                            style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          Container(
                            width: 320,
                            height: 135, //1st container size
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10), //Rounded coruners
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      //To fit the icon good inside the container
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.person),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8, right: 20, top: 8, bottom: 8),
                                      child: Text(
                                        "I'm a user, looking for stores to buy what I want",
                                        style: TextStyle(color: Colors.black, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: _is1stIconChanged ? const Icon(Icons.circle) : const Icon(Icons.circle_outlined),
                                    onPressed: () {
                                      setState(() {
                                        // Change the state of button icon on pressed
                                        _is1stIconChanged = true;
                                        _is2ndIconChanged = false;
                                      });
                                    },
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            //Second container
                            width: 320,
                            height: 135,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.store_mall_directory),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8, right: 25, top: 8, bottom: 8),
                                      child: Text(
                                        "I'm a provider, I have a store and I want to show it in the app",
                                        style: TextStyle(color: Colors.black, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: _is2ndIconChanged ? const Icon(Icons.circle) : const Icon(Icons.circle_outlined),
                                    onPressed: () {
                                      setState(() {
                                        _is2ndIconChanged = true;
                                        _is1stIconChanged = false; //To change the state of the second icon
                                      });
                                    },
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 23), // To empty space between container and (Create) button
                          SizedBox(
                            width: 300,
                            height: 65,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow[700], //Background colour of button
                                foregroundColor: Colors.white, //Text colour
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                // Navigate where to go when pressed user or service provider
                                if (_is1stIconChanged) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const UserLoginAndSignUpScreen(signUpCheck: true)));
                                } else if (_is2ndIconChanged) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProviderLoginAndSignUpScreen(signUpCheck: true)));
                                }
                              },
                              child: const Text(
                                "Create Account", //Text on the button
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 23),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  // Show the custom dialog when tapped
                                  showDialog(
                                    context: context,
                                    builder: (context) => const ChooseRoleDialog(),
                                  );
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(color: Colors.yellow[700], fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
        );
    }
}
