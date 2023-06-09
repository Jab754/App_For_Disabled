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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAmlIK9AHyqGXtSo8lQEhI6UUR3-Bc5mzg',
    appId: '1:965573374437:web:91648001542bbabb7fbf0c',
    messagingSenderId: '965573374437',
    projectId: 'mynotes-miniproj',
    authDomain: 'mynotes-miniproj.firebaseapp.com',
    databaseURL: 'https://mynotes-miniproj-default-rtdb.firebaseio.com',
    storageBucket: 'mynotes-miniproj.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAglsY8zZE99dVxYa2ntGLsNkxmon6Pa8',
    appId: '1:965573374437:android:0b1a943e88d538de7fbf0c',
    messagingSenderId: '965573374437',
    projectId: 'mynotes-miniproj',
    databaseURL: 'https://mynotes-miniproj-default-rtdb.firebaseio.com',
    storageBucket: 'mynotes-miniproj.appspot.com',
  );
}
