import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../mainmenu/home_menu.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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

  bool _isPasswordValid(String password) {
    return password.length >= 8 && password.length <= 10;
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': _emailController.text,
          'username': _usernameController.text,
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeMenu(username: _usernameController.text),
          ),
        );
      } catch (e) {
        // Handle error
        print(e);
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
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              // Logo
              Image.asset(
                'assets/i_read_pic.png',
                width: 75,
                height: 75,
              ),
              SizedBox(height: 10),

              Text(
                "Let's Get You Started!",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Create an account to access I-READ',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                maxLength: 30,
                decoration: InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  hintText: 'Enter E-mail here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Username Field
              TextFormField(
                controller: _usernameController,
                maxLength: 15,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  hintText: 'Enter username here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please input a username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
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
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !_isPasswordValid(value)) {
                    return 'Please input at least 8 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  hintText: 'Confirm password here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Register Button
              ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Register',
                  style: GoogleFonts.montserrat(color: Colors.white),
                ),
              ),

              SizedBox(height: 20),

              // Link to Login
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(color: Colors.white),
                  children: [
                    TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Login here.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
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
