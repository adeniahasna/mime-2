import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/task_provider.dart';
import 'package:provider/provider.dart';
import '/resources/widgets/splash_screen.dart';
import '/bootstrap/app.dart';
import '/config/providers.dart';
import 'package:nylo_framework/nylo_framework.dart';

/* Boot
|--------------------------------------------------------------------------
| The boot class is used to initialize your application.
| Providers are booted in the order they are defined.
|-------------------------------------------------------------------------- */

class Boot {
  /// This method is called to initialize Nylo.
  static Future<Nylo> nylo() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (getEnv('SHOW_SPLASH_SCREEN', defaultValue: false)) {
      runApp(SplashScreen.app());

      await Future.delayed(Duration(seconds: 3));
    }

    await _setup();
    return await bootApplication(providers);
  }

  /// This method is called after Nylo is initialized.
  static Future<void> finished(Nylo nylo) async {
    await bootFinished(nylo, providers);
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => TaskProvider()),
        ],
        child: Main(nylo),
      ),
    );
  }
}

class BottomNavState extends ChangeNotifier {
  int currentIndex = 0;

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }
}

/* Setup
|--------------------------------------------------------------------------
| You can use _setup to initialize classes, variables, etc.
| It's run before your app providers are booted.
|-------------------------------------------------------------------------- */

_setup() async {
  /// Example: Initializing StorageConfig
  // StorageConfig.init(
  //   androidOptions: AndroidOptions(
  //     resetOnError: true,
  //     encryptedSharedPreferences: false
  //   )
  // );
}
