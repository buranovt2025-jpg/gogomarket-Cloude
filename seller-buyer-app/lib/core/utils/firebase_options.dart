import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

// TODO: Replace with output from `flutterfire configure`
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions unsupported for this platform');
    }
  }

  // Replace these placeholder values with actual ones from Firebase Console
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'YOUR_ANDROID_API_KEY',
    appId:             '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId:         'gogomarket-app',
    storageBucket:     'gogomarket-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'YOUR_IOS_API_KEY',
    appId:             '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId:         'gogomarket-app',
    storageBucket:     'gogomarket-app.appspot.com',
    iosClientId:       'YOUR_IOS_CLIENT_ID',
    iosBundleId:       'uz.gogomarket.app',
  );
}
