// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static FirebaseOptions web = FirebaseOptions(
    // apiKey: dotenv.env['FIREBASE_API_KEY_WEB']!,
    // appId: dotenv.env['FIREBASE_APP_ID_WEB']!,
    // messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    // projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    // authDomain: '${dotenv.env['FIREBASE_PROJECT_ID']}.firebaseapp.com',
    // storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
    // measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
    apiKey: 'AIzaSyBw8wlcQDs-gOdwsZ7ayZcqwgrkL4p3RUA',
    appId: '1:263973706990:web:c979ded0db7927e4a2a7ff',
    messagingSenderId: '263973706990',
    projectId: 'buyer-centric-app-ca33e',
    authDomain: 'buyer-centric-app-ca33e.firebaseapp.com',
    storageBucket: 'buyer-centric-app-ca33e.firebasestorage.app',
    measurementId: 'G-8XY3HC35GX',
  );

  static FirebaseOptions android = FirebaseOptions(
    // apiKey: dotenv.env['FIREBASE_API_KEY_ANDROID']!,
    // appId: dotenv.env['FIREBASE_APP_ID_ANDROID']!,
    // messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
    // projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    // storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
    apiKey: 'AIzaSyAwVBz6XJF-eqNG1OvHOFDGVFzhRrV2RGM',
    appId: '1:263973706990:android:b952de9b366114a9a2a7ff',
    messagingSenderId: '263973706990',
    projectId: 'buyer-centric-app-ca33e',
    storageBucket: 'buyer-centric-app-ca33e.firebasestorage.app',
  );
}
