// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBLHhmWPw0jYKWW_ycagZWtElkf_mROfgQ',
    appId: '1:72760345726:web:9f1ddfe1c3d8b668ac442f',
    messagingSenderId: '72760345726',
    projectId: 'clothing-app-8038c',
    authDomain: 'clothing-app-8038c.firebaseapp.com',
    databaseURL: 'https://clothing-app-8038c-default-rtdb.firebaseio.com',
    storageBucket: 'clothing-app-8038c.appspot.com',
    measurementId: 'G-6EX0KYHQ61',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsyDHKikxe5Ep6JfQ-M3KE8jNoABgTRBI',
    appId: '1:72760345726:android:c35557a0d455f561ac442f',
    messagingSenderId: '72760345726',
    projectId: 'clothing-app-8038c',
    databaseURL: 'https://clothing-app-8038c-default-rtdb.firebaseio.com',
    storageBucket: 'clothing-app-8038c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDN8HaOmAAIfvk5ggOm2ax-Lq9QRs5W5sU',
    appId: '1:72760345726:ios:fd3029aab11090e8ac442f',
    messagingSenderId: '72760345726',
    projectId: 'clothing-app-8038c',
    databaseURL: 'https://clothing-app-8038c-default-rtdb.firebaseio.com',
    storageBucket: 'clothing-app-8038c.appspot.com',
    iosBundleId: 'com.example.clothingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDN8HaOmAAIfvk5ggOm2ax-Lq9QRs5W5sU',
    appId: '1:72760345726:ios:6bd7cb982b8993b5ac442f',
    messagingSenderId: '72760345726',
    projectId: 'clothing-app-8038c',
    databaseURL: 'https://clothing-app-8038c-default-rtdb.firebaseio.com',
    storageBucket: 'clothing-app-8038c.appspot.com',
    iosBundleId: 'com.example.clothingApp.RunnerTests',
  );
}