import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../quiz/readcomp_quiz.dart'; // Ensure this path is correct

class ReadingContentPage extends StatelessWidget {
  final String level;
  final List<String> uniqueIds; // Include uniqueIds as a class variable

  const ReadingContentPage({
    super.key,
    required this.level,
    required this.uniqueIds, // Include uniqueIds in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Reading Content - $level', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white, // Set text color to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content for $level Level',
              style: GoogleFonts.montserrat(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Here is where you will display the reading content for the $level level.',
              style: GoogleFonts.montserrat(fontSize: 18),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                print('Unique IDs: $uniqueIds'); // Debug print
                // Navigate to the quiz when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadCompQuiz(
                        moduleTitle: 'Reading Comprehension',
                        uniqueIds: uniqueIds // Pass uniqueIds if needed
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[900], // Change button color
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text('Play Quiz', style: GoogleFonts.montserrat()),
            ),
          ],
        ),
      ),
    );
  }
}
