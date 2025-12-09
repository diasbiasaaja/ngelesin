// main.dart (ubah sedikit)
import 'package:flutter/material.dart';
import 'theme.dart'; // import theme.dart
import 'package:ngelesin/login_guru.dart';
import 'package:ngelesin/role_page.dart';
import 'splash.dart';
import 'log_inuser.dart';
import 'role_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme, // <- apply theme here
      home: const SplashScreen(),
      routes: {
        "/rolePage": (context) => const RolePage(),
        "/LoginGuruPage": (context) => const LoginGuruPage(),
        "/LoginPage": (context) => const LoginPage(),
      },
    );
  }
}
