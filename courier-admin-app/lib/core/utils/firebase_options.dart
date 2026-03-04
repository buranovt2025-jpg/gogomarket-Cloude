import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      default: throw UnsupportedError('Unsupported platform');
    }
  }
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY', appId: '1:000000:android:0000',
    messagingSenderId: '000000', projectId: 'gogomarket-app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY', appId: '1:000000:ios:0000',
    messagingSenderId: '000000', projectId: 'gogomarket-app',
    iosBundleId: 'uz.gogomarket.staff',
  );
}
