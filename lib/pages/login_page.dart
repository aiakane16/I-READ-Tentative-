import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../firestore/firestore_user.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirestoreUser _firestoreUser = FirestoreUser();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  String? _emailError;
  String? _passwordError;

  bool _isEmailValid(String email) {
    final emailRegExp =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  void _validateEmail(String value) {
    if (value.isNotEmpty) {
      if (!_isEmailValid(value)) {
        setState(() {
          _emailError = 'Please input a valid email';
        });
      } else {
        setState(() {
          _emailError = null; // Clear error
        });
      }
    } else {
      setState(() {
        _emailError = null; // No error message for empty input
      });
    }
  }

  bool _isPasswordValid(String password) {
    return password.length >= 8;
  }

  void _validatePassword(String value) {
    if (value.isNotEmpty) {
      if (!_isPasswordValid(value)) {
        setState(() {
          _passwordError = 'Please input at least 8 characters';
        });
      } else {
        setState(() {
          _passwordError = null; // Clear error
        });
      }
    } else {
      setState(() {
        _passwordError = null; // No error message for empty input
      });
    }
  }

  void _handleLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    _validateEmail(email);
    _validatePassword(password);

    if (_emailError == null && _passwordError == null) {
      try {
        await _firestoreUser.signIn(
            email, password); // Use FirestoreUser for login
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please input a registered user account')),
        );
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/i_read_pic.png', width: 120, height: 120),
              SizedBox(height: 20),
              Text('where learning gets better.',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 10),
              Divider(color: Colors.white, thickness: 1),
              SizedBox(height: 20),
              Text('Login',
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
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
                  border: OutlineInputBorder(),
                  hintText: 'Enter E-mail here...',
                  hintStyle: TextStyle(color: Colors.white54),
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                onChanged: _validateEmail,
                buildCounter: (context,
                    {required currentLength, maxLength, required isFocused}) {
                  return null;
                },
              ),
              if (_emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child:
                      Text(_emailError!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                maxLength: 10,
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
                        color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                style: GoogleFonts.montserrat(color: Colors.white),
                onChanged: _validatePassword,
                buildCounter: (context,
                    {required currentLength, maxLength, required isFocused}) {
                  return null;
                },
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_passwordError!,
                      style: TextStyle(color: Colors.red)),
                ),
              SizedBox(height: 20),
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
                  Text('Remember Me',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Login',
                    style: GoogleFonts.montserrat(color: Colors.white)),
              ),
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
                          Navigator.of(context)
                              .pushReplacementNamed('/register');
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
