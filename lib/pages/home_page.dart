import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Page!',
          style: GoogleFonts.montserrat(fontSize: 24),
        ),
      ),
    );
  }
}
