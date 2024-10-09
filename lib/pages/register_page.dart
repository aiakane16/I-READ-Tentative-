import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/functions/form_data.dart';
import 'login_page.dart';
import 'register2_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

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

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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

  Future<void> checkEmailExists(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (result.docs.isNotEmpty) {
      throw Exception('Email already registered');
    }
  }

  void _handleNext() async {
    if (_formKey.currentState!.validate()) {
      try {
        await checkEmailExists(_emailController.text);

        // Temporarily store the email, username, and password in FormData
        FormData().email = _emailController.text;
        FormData().username = _usernameController.text;
        FormData().password = _passwordController.text;

        // Navigate to PersonalInfoPage without creating the user account
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PersonalInfoPage(
              emailController: _emailController,
              usernameController: _usernameController,
              passwordController: _passwordController,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.02),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Image.asset('assets/i_read_pic.png', width: 75, height: 75),
              const SizedBox(height: 10),
              Text(
                "Let's Get You Started!",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Create an account to access I-READ',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Email Field
              TextFormField(
                controller: _emailController,
                maxLength: 30,
                decoration: InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: const OutlineInputBorder(),
                  hintText: 'Enter E-mail here...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.email, color: Colors.white),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: _validateEmail,
                buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) {
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Username Field
              TextFormField(
                controller: _usernameController,
                maxLength: 15,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: const OutlineInputBorder(),
                  hintText: 'Enter username here...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                validator: _validateUsername,
                buildCounter: (context,
                    {required currentLength, required isFocused, maxLength}) {
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: const OutlineInputBorder(),
                  hintText: 'Enter password here...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
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
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.blue[800]?.withOpacity(0.3),
                  border: const OutlineInputBorder(),
                  hintText: 'Confirm password here...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.white),
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
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Next Button
              ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'Next',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Link to Login
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(color: Colors.white),
                  children: <TextSpan>[
                    const TextSpan(text: "Already have an account? "),
                    TextSpan(
                      text: "Login",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
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
