import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/splash_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/register2_page.dart'; // Include Register2Page
import 'mainmenu/home_menu.dart';
import 'mainmenu/modules_menu.dart';
import 'mainmenu/addfield_menu.dart';
import 'mainmenu/profile_menu.dart';
import 'mainmenu/settings_menu.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase
  runApp(MyApp()); // Run your app
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'I-READ App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => SplashPage(), // Start with the SplashPage
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/register2': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, TextEditingController>;
          return PersonalInfoPage(
            emailController: args['emailController']!,
            usernameController: args['usernameController']!,
            passwordController: args['passwordController']!,
            userId: '',
          );
        },
        '/home': (context) => HomeMenu(username: ''),
        '/modules_menu': (context) => ModulesMenu(),
        '/addfield_menu': (context) => AddFieldMenu(),
        '/profile_menu': (context) => ProfilesMenu(),
        '/settings_menu': (context) => SettingsMenu(),
        // Other routes can be added here
      },
    );
  }
}
