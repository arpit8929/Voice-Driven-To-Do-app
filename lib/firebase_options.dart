import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace these values with your Firebase configuration
    return const FirebaseOptions(
      apiKey: 'AIzaSyCL7CA1T0PsYqHf9Gcx2LAT2nlmPwQQIr8',
      appId: '1:80673228979:android:e2109fc53bdca26f5e48c6',
      messagingSenderId: '80673228979',
      projectId: 'voice-driven-to-do-app',
      storageBucket: 'voice-driven-to-do-app.firebasestorage.app',
    );
  }
}