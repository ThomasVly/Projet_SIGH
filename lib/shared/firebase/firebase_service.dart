import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'firebase_options.dart';

class FirebaseService {
  static bool _initialized = false;


  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    WidgetsFlutterBinding.ensureInitialized();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    _initialized = true;
  }

  /// Check if Firebase has been initialized.
  static bool get isInitialized => _initialized;
}
