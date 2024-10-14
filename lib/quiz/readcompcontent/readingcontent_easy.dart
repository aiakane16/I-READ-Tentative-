import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_read_app/quiz/readcompdifficulty/readcomp_1.dart'; // Ensure this path is correct

class ReadingContentPage extends StatelessWidget {
  final String level;
  final List<String> uniqueIds;

  const ReadingContentPage({
    super.key,
    required this.level,
    required this.uniqueIds,
  });

  @override
  Widget build(BuildContext context) {
    String difficulty = determineDifficulty(uniqueIds); // Determine difficulty

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title:
            Text('Reading Content - $level', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white, // Set text color to white
      ),
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
        child: SingleChildScrollView(
          // Make the body scrollable
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Topic Title',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Change text color to white
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: Colors.white, thickness: 2), // Underline
              const SizedBox(height: 20),
              Text(
                'Here is where you will display the reading content for the $level level.',
                style:
                    GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(height: 40), // Space before the button
              Center(
                // Center the button
                child: ElevatedButton(
                  onPressed: () {
                    print('Unique IDs: $uniqueIds'); // Debug print
                    // Navigate to the short story page when the button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReadCompQuiz(
                          moduleTitle: 'Reading Comprehension',
                          difficulty:
                              difficulty, // Pass the actual difficulty level
                          uniqueIds: uniqueIds,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900], // Change button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: Text(
                    'Play the quiz!',
                    style: GoogleFonts.montserrat(
                      color: Colors.white, // Change button text color to white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String determineDifficulty(List<String> uniqueIds) {
    // Determine the difficulty based on unique IDs
    if (uniqueIds.contains('myoLYQD0ML1gWuSI0t1U')) {
      return 'Easy';
    } else if (uniqueIds.contains('2jOvLgO48hHIMAwpi1qx')) {
      return 'Medium';
    } else if (uniqueIds.contains('JBTrWkZJjYfSSwvQUl9Z')) {
      return 'Hard';
    }
    return 'Unknown'; // Default case
  }
}
