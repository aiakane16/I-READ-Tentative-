import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/services/storage.dart';
import '../indevelop.dart';
import '../quiz/sentcompcontent/sentcompdifficulty/sentcomp_1.dart';

class SentenceCompositionLevels extends StatefulWidget {
  const SentenceCompositionLevels({super.key});

  @override
  _SentenceCompositionLevelsState createState() =>
      _SentenceCompositionLevelsState();
}

class _SentenceCompositionLevelsState extends State<SentenceCompositionLevels> {
  String userId = '';
  final String easyId = 'm91vLaASKnJf23AYwoDj'; // Easy unique ID
  final String mediumId = 'yVZ7S6Wo5QIOLRF8Npmx'; // Medium unique ID
  final String hardId = '12HN1FAdEff0Juxv36Bv'; // Hard unique ID

  bool isEasyCompleted = false;
  bool isMediumCompleted = false;
  bool isHardCompleted = false;
  StorageService storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();

  }

  Future<void> _checkCompletionStatus() async {
    List<Module> modules = await storageService.getModules();
    Module easyModule = modules.where((element) => element.difficulty == 'Easy' && element.category == 'Sentence Composition').last;
    Module mediumModule = modules.where((element) => element.difficulty == 'Medium' && element.category == 'Sentence Composition').last;
    Module hardModule = modules.where((element) => element.difficulty == 'Hard' && element.category == 'Sentence Composition').last;

    setState(() {
      isEasyCompleted = !easyModule.isLocked; // Track completion for Easy
      isMediumCompleted = !mediumModule.isLocked; 
      isHardCompleted = !hardModule.isLocked; // Track completion for Hard
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sentence Composition Levels',
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
              if (level == 'Easy') {
                // Fetch unique IDs for the Easy level
                List<String> uniqueIds = await _fetchUniqueIds('Easy');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SentCompQuiz(
                      title: 'Sentence Composition',
                      uniqueIds: uniqueIds, // Pass unique IDs
                      difficulty: 'Easy', // Pass difficulty level
                    ),
                  ),
                ).then((result) {
                  // Handle completion result for Easy level
                  if (result == true) {
                    // _updateUserProgress(); // Update progress on completion
                  }
                });
              } else if (level == 'Medium') {
                // Navigate to the Medium content page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DevelopmentScreen(),
                  ),
                ).then((result) {
                  // Handle completion result for Medium level
                  if (result == true) {
                    // _onLevelCompleted(level);
                  }
                });
              } else if (level == 'Hard') {
                // Navigate to the Hard content page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DevelopmentScreen(),
                  ),
                ).then((result) {
                  // Handle completion result for Hard level
                  if (result == true) {
                    // _onLevelCompleted(level);
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
    // Return the unique IDs based on difficulty level
    switch (difficulty) {
      case 'Easy':
        return [easyId];
      case 'Medium':
        return [mediumId];
      case 'Hard':
        return [hardId];
      default:
        return [];
    }
  }
}
