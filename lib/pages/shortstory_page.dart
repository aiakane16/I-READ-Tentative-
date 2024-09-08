import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShortStoryPage extends StatefulWidget {
  final String shortStory;
  final VoidCallback onComplete;

  const ShortStoryPage(
      {super.key, required this.shortStory, required this.onComplete});

  @override
  _ShortStoryPageState createState() => _ShortStoryPageState();
}

class _ShortStoryPageState extends State<ShortStoryPage> {
  int _secondsLeft = 5; // Set to 30 seconds

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
        _startTimer();
      } else {
        widget.onComplete(); // Call the callback when time is up
        Navigator.pop(context); // Automatically pop the story page
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Read the Story', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blue[900],
        automaticallyImplyLeading: false, // Remove the back arrow
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Time: $_secondsLeft',
              style: GoogleFonts.montserrat(fontSize: 18),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF0052CC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              widget.shortStory,
              style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
