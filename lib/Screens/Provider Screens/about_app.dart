import 'package:authentication/Screens/Provider%20Screens/provider_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../User Screens/user_profile.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProviderHomeScreen(
                          navBarIndex: 0,
                        )));
          },
          child: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(255, 198, 50, 1),
        elevation: 0,
      ),
      body: Container(
        color: const Color.fromRGBO(255, 198, 50, 1),
        child: Column(
          children: [
            Lottie.asset(
              "lib/assets/jsonImage/Animation - 1709834311796.json",
            ),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "KUB is a leading online order service that operates in Egypt. "
                "We seamlessly connect customers with their favorite brands. "
                "It takes just few taps from our platform to place an order "
                "through KUB from your favorite place.",
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    fontSize: 27),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
