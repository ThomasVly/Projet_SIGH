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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-EhQVDnr619EeiNJo7Mjn2JvvozwyIB0',
    appId: '1:35428473210:android:ea20868b70aa3fcf0b1ec3',
    messagingSenderId: '35428473210',
    projectId: 'sighg1-29498',
    storageBucket: 'sighg1-29498.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDwqBca_lOuCcd7aTaYI5WoW1GDKndq2ho',
    appId: '1:35428473210:web:2b4574b94feea1870b1ec3',
    authDomain: "sighg1-29498.firebaseapp.com",
    messagingSenderId: '35428473210',
    projectId: 'sighg1-29498',
    storageBucket: 'sighg1-29498.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUdPbcVyU4hSDlGCVTosGtCvE1QrJRwmo',
    appId: '1:35428473210:ios:1cf180969159c37b0b1ec3',
    messagingSenderId: '35428473210',
    projectId: 'sighg1-29498',
    storageBucket: 'sighg1-29498.appspot.com',
    iosBundleId: 'fisa5.sigh',
  );
}
