// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyDmZUWgqSxYh1wWn9I80IENxn0rJ6lTrjc',
    appId: '1:519970302927:web:932716894ba90bec8700ba',
    messagingSenderId: '519970302927',
    projectId: 'employee-id25',
    authDomain: 'employee-id25.firebaseapp.com',
    storageBucket: 'employee-id25.firebasestorage.app',
    measurementId: 'G-R8K92YGQ07',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD556A8L1_mS2rfmFxunJen00tyCamntJE',
    appId: '1:519970302927:android:befb198edb1cff0c8700ba',
    messagingSenderId: '519970302927',
    projectId: 'employee-id25',
    storageBucket: 'employee-id25.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOMCEzZYzP5D57y7mTKPaQsYo9czVsRqY',
    appId: '1:519970302927:ios:02332f8ed6260b6e8700ba',
    messagingSenderId: '519970302927',
    projectId: 'employee-id25',
    storageBucket: 'employee-id25.firebasestorage.app',
    iosBundleId: 'com.example.employeeId',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAOMCEzZYzP5D57y7mTKPaQsYo9czVsRqY',
    appId: '1:519970302927:ios:02332f8ed6260b6e8700ba',
    messagingSenderId: '519970302927',
    projectId: 'employee-id25',
    storageBucket: 'employee-id25.firebasestorage.app',
    iosBundleId: 'com.example.employeeId',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDmZUWgqSxYh1wWn9I80IENxn0rJ6lTrjc',
    appId: '1:519970302927:web:4ea7bc859cfbeb148700ba',
    messagingSenderId: '519970302927',
    projectId: 'employee-id25',
    authDomain: 'employee-id25.firebaseapp.com',
    storageBucket: 'employee-id25.firebasestorage.app',
    measurementId: 'G-HWGEDDJFRK',
  );
}
