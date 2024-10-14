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
    } else if (value.length > 10) {
      return 'Username must be at most 10 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty || !_isPasswordValid(value)) {
      return 'Password must be 8-10 characters';
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
    final result = await FirebaseFirestore.instance
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent, // Set to transparent
      body: Container(
        height: MediaQuery.of(context).size.height, // Full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.1,
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/i_read_pic.png', width: 75, height: 75),
                const SizedBox(height: 20),
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
                _buildTextField(
                  controller: _emailController,
                  label: 'E-Mail',
                  hint: 'Enter E-mail here...',
                  icon: Icons.email,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),

                // Username Field
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Enter username here...',
                  icon: Icons.person,
                  validator: _validateUsername,
                  maxLength: 10, // Restrict max length to 10 characters
                ),
                const SizedBox(height: 20),

                // Password Field
                _buildPasswordField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter password here...',
                  isVisible: _isPasswordVisible,
                  toggleVisibility: _togglePasswordVisibility,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),

                // Confirm Password Field
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm password here...',
                  isVisible: _isConfirmPasswordVisible,
                  toggleVisibility: _toggleConfirmPasswordVisibility,
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 20),

                // Next Button
                ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 20),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int? maxLength, // Optional maxLength parameter
  }) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength, // Set maxLength if provided
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.blue[800]?.withOpacity(0.3),
        border: const OutlineInputBorder(),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white),
      ),
      style: GoogleFonts.montserrat(color: Colors.white),
      validator: validator,
      buildCounter: (context,
          {required currentLength, required isFocused, maxLength}) {
        return const SizedBox.shrink(); // Hides the character limit
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      maxLength: 10,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.blue[800]?.withOpacity(0.3),
        border: const OutlineInputBorder(),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: toggleVisibility,
        ),
      ),
      style: GoogleFonts.montserrat(color: Colors.white),
      validator: validator,
      buildCounter: (context,
          {required currentLength, required isFocused, maxLength}) {
        return const SizedBox.shrink(); // Hides the character limit
      },
    );
  }
}
