import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/readingcontent_page';

class ReadingComprehensionLevels extends StatelessWidget {
  const ReadingComprehensionLevels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Comprehension Levels',
            style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLevelButton(context, 'Easy'),
                _buildLevelButton(context, 'Medium'),
                _buildLevelButton(context, 'Hard'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String level) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReadingContentPage(level: level), // Navigate to content page
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Change button color
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      ),
      child: Text(level, style: GoogleFonts.montserrat(fontSize: 24)),
    );
  }
}
