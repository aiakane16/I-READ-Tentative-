import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'intro_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFadeInAnimation;
  late Animation<double> _textFadeInAnimation;
  late Animation<double> _buttonFadeInAnimation;
  late Animation<Offset> _slideUpAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _logoFadeInAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _textFadeInAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.4, 1.0, curve: Curves.easeIn),
    ));

    _slideUpAnimation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, -0.5))
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _buttonFadeInAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    _controller.forward(); // Start animations without auto-navigation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 200), // Space above the logo
            SlideTransition(
              position: _slideUpAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoFadeInAnimation,
                    child: Image.asset(
                      'assets/i_read_pic.png',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  SizedBox(height: 10),
                  FadeTransition(
                    opacity: _textFadeInAnimation,
                    child: Text(
                      'where learning gets better.',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FadeTransition(
                    opacity: _buttonFadeInAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 295, // Adjusted width for Log In button
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .blue[600], // Blue background for Log In
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              minimumSize: Size(double.infinity, 50),
                            ),
                            child: Text(
                              'Log In',
                              style: GoogleFonts.montserrat(
                                color:
                                    Colors.white, // Explicitly set white text
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 250, // Width for Sign Up button
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => IntroPage()),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  Colors.transparent, // Fully transparent
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 20),
                              minimumSize: Size(double.infinity, 50),
                              side: BorderSide(
                                  color: Colors.blue[600]!), // Blue border
                            ),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // White text for Sign Up
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40), // Padding below the buttons
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
