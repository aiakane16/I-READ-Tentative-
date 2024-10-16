import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../indevelop.dart';
import '../quiz/readcompcontent/readingcontent_readcomp/readingcontent_easy.dart'; // Import your ReadingContentPage

class ReadingComprehensionLevels extends StatefulWidget {
  const ReadingComprehensionLevels({super.key});

  @override
  _ReadingComprehensionLevelsState createState() =>
      _ReadingComprehensionLevelsState();
}

class _ReadingComprehensionLevelsState
    extends State<ReadingComprehensionLevels> {
  String userId = '';
  late String easyId;
  final String mediumId =
      'your_medium_unique_id'; // Replace with actual medium ID
  final String hardId = 'your_hard_unique_id'; // Replace with actual hard ID

  bool isEasyCompleted = false;
  bool isMediumCompleted = false;
  bool isHardCompleted = false;

  @override
  void initState() {
    super.initState();
    _getUserId().then((id) {
      setState(() {
        userId = id;
        easyId = '$userId-Reading Comprehension-Easy'; // Generate easy ID
      });
      _checkCompletionStatus();
    });
  }

  Future<void> _checkCompletionStatus() async {
    await _checkDifficultyStatus(userId, easyId).then((completed) {
      setState(() {
        isEasyCompleted = completed;
      });
    });

    await _checkDifficultyStatus(userId, mediumId).then((completed) {
      setState(() {
        isMediumCompleted = completed;
      });
    });

    await _checkDifficultyStatus(userId, hardId).then((completed) {
      setState(() {
        isHardCompleted = completed;
      });
    });
  }

  Future<String> _getUserId() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      return user?.uid ??
          ''; // Return the user ID or an empty string if not found
    } catch (e) {
      print('Error fetching user ID: $e');
      return ''; // Default to an empty string
    }
  }

  Future<bool> _checkDifficultyStatus(
      String userId, String difficultyId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc('Reading Comprehension')
          .collection('difficulty')
          .doc(difficultyId)
          .get();

      if (snapshot.exists) {
        return snapshot['status'] == 'COMPLETED';
      }
    } catch (e) {
      print('Error checking difficulty status for $difficultyId: $e');
    }
    return false; // Default to not completed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading Comprehension Levels',
            style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
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
                isEasyCompleted), // Unlocked if Easy is completed
            const SizedBox(height: 20),
            _buildLevelButton(context, 'Hard',
                isMediumCompleted), // Unlocked if Medium is completed
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
              if (level == 'Medium') {
                // Navigate to the development screen if Medium is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DevelopmentScreen(),
                  ),
                );
              } else {
                // For Easy and Hard levels
                List<String> uniqueIds = await _fetchUniqueIds(level);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadingContentPage(
                      level: level,
                      uniqueIds: uniqueIds,
                    ),
                  ),
                ).then((result) {
                  // Assume result is a boolean indicating completion
                  if (result == true) {
                    _onLevelCompleted(level);
                  }
                });
              }
            }
          : null, // Disable button if locked
      style: ElevatedButton.styleFrom(
        backgroundColor: isUnlocked
            ? (level == 'Easy' && isEasyCompleted
                ? Colors.green
                : (level == 'Medium' && isMediumCompleted
                    ? Colors.green
                    : (level == 'Hard' && isHardCompleted
                        ? Colors.green
                        : Colors.blue)))
            : Colors.grey,
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
          .collection(difficulty)
          .get();

      for (var doc in snapshot.docs) {
        uniqueIds.add(doc.id);
      }
    } catch (e) {
      print('Error fetching unique IDs for $difficulty: $e');
    }

    return uniqueIds;
  }

  void _onLevelCompleted(String level) {
    setState(() {
      if (level == 'Easy') {
        isEasyCompleted = true;
      } else if (level == 'Medium') {
        isMediumCompleted = true;
      } else if (level == 'Hard') {
        isHardCompleted = true;
      }
    });
  }
}
