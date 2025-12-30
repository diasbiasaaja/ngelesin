// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart'; // <- WAJIB
import 'theme/theme.dart';
import 'package:ngelesin/pages/login/login_guru.dart';
import 'package:ngelesin/pages/pembukaan/role_page.dart';
import 'package:ngelesin/pages/pembukaan/splash.dart';
import 'package:ngelesin/pages/login/log_inuser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <- WAJIB
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme, // <- TETAP
      home: const SplashScreen(), // <- TETAP
      routes: {
        "/rolePage": (context) => const RolePage(),
        "/LoginGuruPage": (context) => const LoginGuruPage(),
        "/LoginPage": (context) => const LoginPage(),
      },
    );
  }
}
