import 'package:flutter/material.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'mainmenu/home_menu.dart';
import 'mainmenu/modules_menu.dart';
import 'mainmenu/addfield_menu.dart';
import 'mainmenu/profile_menu.dart';
import 'mainmenu/settings_menu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I-READ App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashPage(), // Start with the SplashPage
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomeMenu(username: ''),
        '/modules_menu': (context) => ModulesMenu(),
        '/addfield_menu': (context) => AddFieldMenu(),
        '/profile_menu': (context) => ProfileMenu(),
        '/settings_menu': (context) => SettingsMenu(),
      },
    );
  }
}
