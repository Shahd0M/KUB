import 'dart:io';
import 'package:authentication/Provider/provider.dart';
import 'package:authentication/Screens/User%20Screens/user_favourites.dart';
import 'package:authentication/Screens/User%20Screens/user_home_screen.dart';
import 'package:authentication/Screens/User%20Screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'Screens/Main Screens/splash_screen.dart';
import 'Screens/User Screens/user_cart.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
          apiKey: "AIzaSyCuhKQxQ4cWCCTiZI_l-PjC9h1HIn9t1A0",
          appId: "1:677661423202:android:8f2585e0707f947d14833b",
          messagingSenderId: "677661423202",
          projectId: "graduationproject-4a15a",
          storageBucket: "graduationproject-4a15a.appspot.com",
          ))
      : await Firebase.initializeApp();
  // Initialize the provider and update theme based on system brightness
  final uiProvider = UiProvider();
  await uiProvider.init();
  runApp(
    ChangeNotifierProvider.value(
      value: uiProvider,
      child: const Kub(),
    ),
  );
}

class Kub extends StatelessWidget {
  const Kub({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => UiProvider()..init(),
      child:
          Consumer<UiProvider>(builder: (context, UiProvider notifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: notifier.isDark ? ThemeMode.dark : ThemeMode.light,
          darkTheme: notifier.isDark ? notifier.darkTheme : notifier.lightTheme,
          theme: notifier.lightTheme,
          home: const SplashScreen(),
          routes: {
            '/userHome': (context) => const UserHomeScreen(navBarIndex: 0),
            '/userProfile': (context) =>
                const UserProfileTab(navBarIndex: 1), // Add your profile screen
            '/userFavorites': (context) => const UserFavouritesTab(
                navBarIndex: 2), // Add your favorites screen
            '/userCart': (context) =>
                const CartScreen(navBarIndex: 3),
            // Add your cart screen
            // Add other routes as needed
          },
        );
      }),
    );
  }
}

void showToast({required String message}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3,
    backgroundColor: Colors.blue,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
