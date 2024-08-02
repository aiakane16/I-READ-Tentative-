import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mainmenu/home_menu.dart';
import 'login_page.dart';
import 'register2_page.dart'; // Import the PersonalInfoPage

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

  bool _isPasswordVisible = false; // Track password visibility
  bool _isConfirmPasswordVisible = false; // Track confirm password visibility

  bool _isPasswordValid(String password) {
    return password.length >= 8 && password.length <= 10;
  }

  bool _isEmailValid(String email) {
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please input a valid email';
    } else if (!_isEmailValid(value)) {
      return 'Please input a valid email';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please input a username';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || !_isPasswordValid(value)) {
      return 'Please input at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    } else if (!_isPasswordValid(value)) {
      return 'Password must be between 8 to 10 characters';
    } else if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
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
          autovalidateMode: AutovalidateMode.onUserInteraction,
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

// Email Field in Register Page
              TextFormField(
                controller: _emailController,
                maxLength: 30, // Set max length to 30
                decoration: InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  hintText: 'Enter E-mail here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: _validateEmail,
                buildCounter: (context,
                    {required int currentLength,
                    required bool isFocused,
                    int? maxLength}) {
                  return null; // Prevent showing the "0/30" text
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
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  hintText: 'Enter username here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: _validateUsername,
                buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) {
                  return null; // Prevent showing the "0/15" text
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
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
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
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: _validatePassword,
                buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) {
                  return null; // Prevent showing the "0/10" text
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
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
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
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: _validateConfirmPassword,
                buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) {
                  return null; // Prevent showing the "0/10" text
                },
              ),
              SizedBox(height: 20),

// Next Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Navigate to PersonalInfoPage
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => PersonalInfoPage(
                          emailController: _emailController,
                          usernameController: _usernameController,
                          passwordController: _passwordController,
                        ),
                      ),
                    )
                        .then((result) {
                      // After PersonalInfoPage is done, navigate to HomePage
                      if (result != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeMenu(username: _usernameController.text),
                          ),
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Next',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 20),

// Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: LinearProgressIndicator(
                  value: 2 / 3,
                  backgroundColor: Colors.grey[400],
                  color: Colors.blue,
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
                              builder: (context) => LoginPage(),
                            ),
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
