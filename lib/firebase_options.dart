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
    apiKey: 'AIzaSyBrq2gUgyBZ2ePAGEGBs35CUnsqHAQyST0',
    appId: '1:605887624146:web:fef691682402a3c5828e0b',
    messagingSenderId: '605887624146',
    projectId: 'crudapp-ce46c',
    authDomain: 'crudapp-ce46c.firebaseapp.com',
    storageBucket: 'crudapp-ce46c.appspot.com',
    measurementId: 'G-6N96KZ0JSX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqWhOgfYiX_bmDyzU13f88tfHD-qV-E3M',
    appId: '1:605887624146:android:bffe0c636a6a724b828e0b',
    messagingSenderId: '605887624146',
    projectId: 'crudapp-ce46c',
    storageBucket: 'crudapp-ce46c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoESMxIDHKG-EFfytxRbEiEq5jsCGWUhM',
    appId: '1:605887624146:ios:efeb5001cca03b06828e0b',
    messagingSenderId: '605887624146',
    projectId: 'crudapp-ce46c',
    storageBucket: 'crudapp-ce46c.appspot.com',
    iosBundleId: 'com.example.flutterapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBoESMxIDHKG-EFfytxRbEiEq5jsCGWUhM',
    appId: '1:605887624146:ios:02945978016ef20d828e0b',
    messagingSenderId: '605887624146',
    projectId: 'crudapp-ce46c',
    storageBucket: 'crudapp-ce46c.appspot.com',
    iosBundleId: 'com.example.flutterapp.RunnerTests',
  );
}
