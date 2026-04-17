import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAVP3P6upDSoArPZ00M1RGD_wQ5GbX4Nkg',
    appId: '1:66350788000:web:56605491267b0506e908c5',
    messagingSenderId: '66350788000',
    projectId: 'lavify-c0b88',
    authDomain: 'lavify-c0b88.firebaseapp.com',
    storageBucket: 'lavify-c0b88.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5Ju9H2f4FMzcCQdNCIXwjWUy9ETyizeY',
    appId: '1:66350788000:android:ea8fbbe964a37e7de908c5',
    messagingSenderId: '66350788000',
    projectId: 'lavify-c0b88',
    storageBucket: 'lavify-c0b88.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXcO1iGUlTeGV8o3Vb0TECinGOBp8m2pY',
    appId: '1:66350788000:ios:6ddbdf47c81721c5e908c5',
    messagingSenderId: '66350788000',
    projectId: 'lavify-c0b88',
    storageBucket: 'lavify-c0b88.firebasestorage.app',
    androidClientId: '66350788000-rh2p0imbfn0mk8jh83459damuih93704.apps.googleusercontent.com',
    iosClientId: '66350788000-apuggsrh6k0g7uertcctes1rr4h23a7a.apps.googleusercontent.com',
    iosBundleId: 'com.example.lavifyApp',
  );

}