// main.dart (ubah sedikit)
import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'package:ngelesin/pages/login/login_guru.dart';
import 'package:ngelesin/pages/pembukaan/role_page.dart';
import 'package:ngelesin/pages/pembukaan/splash.dart';
import 'package:ngelesin/pages/login/log_inuser.dart';
import 'package:ngelesin/pages/pembukaan/role_page.dart';

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
