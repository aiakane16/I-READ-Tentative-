import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WordPronunciationContentHard extends StatelessWidget {
  const WordPronunciationContentHard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Pronunciation - Hard Level',
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Challenge your pronunciation skills with these advanced words:',
                style:
                    GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Logic for starting the pronunciation practice
                  // For example, navigate to the quiz page or start the practice
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  'Start Hard Practice',
                  style:
                      GoogleFonts.montserrat(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
