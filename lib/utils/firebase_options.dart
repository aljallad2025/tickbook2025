// GENERATED-LIKE PLACEHOLDER: Replace this file by running `flutterfire configure`.
// This placeholder enables compilation and Android runtime using values from
// android/app/google-services.json. For iOS, macOS, and Web you MUST run the
// FlutterFire CLI to generate the real options.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions for Web are not configured. Run `flutterfire configure`.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'FirebaseOptions for iOS are not configured. Run `flutterfire configure`.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'FirebaseOptions for macOS are not configured. Run `flutterfire configure`.',
        );
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Values derived from android/app/google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBLnbe1IedScsDrXdbZkqXdNIebrx0QETE',
    appId: '1:344416525839:android:4af94da0d6cc53d2674d7a',
    messagingSenderId: '344416525839',
    projectId: 'evento-4df74',
    storageBucket: 'evento-4df74.firebasestorage.app',
  );
}
