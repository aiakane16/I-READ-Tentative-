import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'intro_page.dart'; // Import the IntroPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBVfRzUF6fklJTckRC5n-G4WUKNy8qBj_o",
        authDomain: "i-read-tentative.firebaseapp.com",
        databaseURL:
            "https://i-read-tentative-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "i-read-tentative",
        storageBucket: "i-read-tentative.appspot.com",
        messagingSenderId: "211486070399",
        appId: "1:211486070399:web:2edb63d1d51d58a51c514a",
        measurementId: "G-64MRZZP3LD",
      ),
    );
  }

  void _handleLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (_emailError == null && _passwordError == null) {
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        setState(() {
          _emailError = 'Invalid email or password.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/i_read_pic.png',
                width: 120,
                height: 120,
              ),
              SizedBox(height: 20),
              Text(
                'where learning gets better.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.white, thickness: 1),
              SizedBox(height: 20),

              // Login Text
              Text(
                'Login',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: OutlineInputBorder(),
                  hintText: 'Enter E-mail here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: OutlineInputBorder(),
                  hintText: 'Enter password here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
              SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
              ),

              SizedBox(height: 20),

              // Sign Up Link
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(color: Colors.white),
                  children: [
                    TextSpan(text: "Don't have an Account? "),
                    TextSpan(
                      text: 'Sign Up here.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => IntroPage()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
