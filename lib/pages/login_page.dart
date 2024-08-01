import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'intro_page.dart'; // Import the IntroPage
import 'home_page.dart'; // Import the HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _rememberMe = false; // Track the state of the checkbox
  bool _isPasswordVisible = false; // Track password visibility
  String? _emailError;
  String? _passwordError;

  bool _isEmailValid(String email) {
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  void _validateEmail(String value) {
    if (value.isEmpty) {
      setState(() {
        _emailError = 'Please input a valid email';
      });
    } else if (!_isEmailValid(value)) {
      setState(() {
        _emailError = 'Please input a valid email';
      });
    } else if (value.length > 30) {
      setState(() {
        _emailError = 'Email must be 30 characters or less';
      });
    } else {
      setState(() {
        _emailError = null; // Clear error
      });
    }
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8 && password.length <= 10;
  }

  void _validatePassword(String value) {
    if (value.isEmpty || !_isPasswordValid(value)) {
      setState(() {
        _passwordError = 'Password must be between 8 to 10 characters';
      });
    } else {
      setState(() {
        _passwordError = null; // Clear error
      });
    }
  }

  void _handleLogin() {
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    // Check if there are any errors
    if (_emailError == null && _passwordError == null) {
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Login'),
        content: Text(
            'Email: ${_emailController.text}\nPassword: ${_passwordController.text}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => HomePage()), // Redirect to HomePage
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
              SizedBox(height: 10), // Space above divider
              Divider(color: Colors.white, thickness: 1), // Line between texts
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
                maxLength: 30,
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
                onChanged: _validateEmail, // Validate on input change
                buildCounter: (context,
                    {required int currentLength,
                    required bool isFocused,
                    int? maxLength}) {
                  return null; // Prevent showing the "0/30" text
                },
              ),
              if (_emailError != null) // Show email error
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _emailError!,
                    style: TextStyle(color: Colors.red),
                  ),
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
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                onChanged: _validatePassword, // Validate on input change
                buildCounter: (context,
                    {required int currentLength,
                    required bool isFocused,
                    int? maxLength}) {
                  return null; // Prevent showing the "0/10" text
                },
              ),
              if (_passwordError != null) // Show password error
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _passwordError!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 20),

              // Remember Me Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                    activeColor: Colors.blue[600],
                  ),
                  Text(
                    'Remember Me',
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: 20), // Space between checkbox and login button

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
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Sign Up Link
              SizedBox(height: 20),
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
