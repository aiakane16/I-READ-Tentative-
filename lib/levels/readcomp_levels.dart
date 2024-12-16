import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/services/storage.dart';
import '../indevelop.dart';
import '../quiz/readcompcontent/readingcontent_readcomp/readingcontent_readcomp.dart'; // Import your ReadingContentPage

class ReadingComprehensionLevels extends StatefulWidget {
  const ReadingComprehensionLevels({super.key});

  @override
  _ReadingComprehensionLevelsState createState() =>
      _ReadingComprehensionLevelsState();
}

class _ReadingComprehensionLevelsState
    extends State<ReadingComprehensionLevels> {
  String userId = '';
  final String moduleName = 'Reading Comprehension';
  final String easyId = 'myoLYQD0ML1gWuSI0t1U'; // Unique ID for Easy level
  final String mediumId = '2jOvLgO48hHIMAwpi1qx'; // Unique ID for Medium level
  final String hardId = 'JBTrWkZJjYfSSwvQUl9Z'; // Unique ID for Hard level
  StorageService storageService = StorageService();

  bool isEasyCompleted = false;
  bool isMediumCompleted = false;
  bool isHardCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkCompletionStatus();
  }

  Future<void> _checkCompletionStatus() async {
    await _fetchDifficultyStatuses();
  }

  Future<void> _fetchDifficultyStatuses() async {
    List<Module> modules = await storageService.getModules();
    Module easyModule = modules.where((element) => element.difficulty == 'Easy' && element.category == 'Reading Comprehension').last;
    Module mediumModule = modules.where((element) => element.difficulty == 'Medium' && element.category == 'Reading Comprehension').last;
    Module hardModule = modules.where((element) => element.difficulty == 'Hard' && element.category == 'Reading Comprehension').last;

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
              // Fetch unique IDs for the level
              List<String> uniqueIds = await _fetchUniqueIds(level);
              List<Module> modules = await storageService.getModules();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReadingContentPageReadComp1(
                    level: level,
                    uniqueIds: uniqueIds,
                    title: modules.where((element) => element.difficulty == level && element.category == 'Reading Comprehension').last.title,
                  ),
                ),
              ).then((result) {
                // Assume result is a boolean indicating completion
                if (result == true) {
                  // _updateUserProgress(level); // Update progress on completion
                }
              });
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
    if (difficulty == 'Easy') {
      return [easyId];
    } else if (difficulty == 'Medium') {
      return [mediumId];
    } else if (difficulty == 'Hard') {
      return [hardId];
    }
    return [];
  }
}
