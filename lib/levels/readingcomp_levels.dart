import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/readingcontent_page.dart'; // Import your ReadingContentPage

class ReadingComprehensionLevels extends StatelessWidget {
  const ReadingComprehensionLevels({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Comprehension Levels',
            style: GoogleFonts.montserrat()),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLevelButton(context, 'Easy', true), // Always unlocked
            const SizedBox(height: 20),
            _buildLevelButton(context, 'Medium',
                false), // Placeholder for actual completion logic
            const SizedBox(height: 20),
            _buildLevelButton(context, 'Hard',
                false), // Placeholder for actual completion logic
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(
      BuildContext context, String level, bool isUnlocked) {
    return ElevatedButton(
      onPressed: isUnlocked
          ? () async {
              List<String> uniqueIds = await _fetchUniqueIds(level);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadingContentPage(
                      level: level, uniqueIds: uniqueIds // Pass unique IDs
                      ),
                ),
              );
            }
          : null, // Disable button if locked
      style: ElevatedButton.styleFrom(
        backgroundColor: isUnlocked ? Colors.blue : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isUnlocked) ...[
            const Icon(Icons.lock, color: Colors.white),
            const SizedBox(width: 10),
          ],
          Text(
            level,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _fetchUniqueIds(String difficulty) async {
    List<String> uniqueIds = [];

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc('Reading Comprehension')
          .collection(difficulty) // Fetching based on difficulty
          .get();

      for (var doc in snapshot.docs) {
        uniqueIds.add(doc.id); // Add unique ID to the list
      }
    } catch (e) {
      // Handle error (optional: show a message to the user)
    }

    return uniqueIds;
  }
}
