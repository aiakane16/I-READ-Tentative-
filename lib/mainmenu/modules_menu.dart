import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_read_app/levels/readingcomp_levels.dart';
import '../quiz/sentcomp_quiz.dart';
import '../quiz/vocabskill_quiz.dart';
import '../quiz/wordpro_quiz.dart';

class ModulesMenu extends StatefulWidget {
  final Function(List<String>) onModulesUpdated;

  const ModulesMenu({super.key, required this.onModulesUpdated});

  @override
  _ModulesMenuState createState() => _ModulesMenuState();
}

class _ModulesMenuState extends State<ModulesMenu> {
  List<String> modules = [];
  List<String> moduleStatuses = [];
  List<int> moduleCompleted = []; // Track completed quizzes for each module
  List<int> moduleTotal = []; // Track total quizzes for each module
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadModules(); // Load modules when dependencies change
  }

  Future<void> _loadModules() async {
    try {
      var fieldDocs =
          await FirebaseFirestore.instance.collection('fields').get();
      List<String> fetchedModules = [];

      // Add "Reading Comprehension" as a module
      fetchedModules.add('Reading Comprehension');

      for (var fieldDoc in fieldDocs.docs) {
        var modulesData = fieldDoc.data()['modules'] as List<dynamic>? ?? [];
        fetchedModules
            .addAll(modulesData.map((module) => module['title'] as String));
      }

      await _fetchModuleStatuses(fetchedModules);

      // Initialize completed and total counts
      moduleCompleted = List.filled(fetchedModules.length, 0);
      moduleTotal = List.filled(
          fetchedModules.length, 3); // Assume 3 for Reading Comprehension

      setState(() {
        modules = fetchedModules;
        isLoading = false;
      });
    } catch (e) {
      _showErrorDialog('Error loading modules: $e');
    }
  }

  Future<void> _fetchModuleStatuses(List<String> fetchedModules) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    List<String> statuses = [];

    for (String module in fetchedModules) {
      var moduleDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(module)
          .get();

      if (moduleDoc.exists) {
        var data = moduleDoc.data() as Map<String, dynamic>;
        statuses.add(data['status'] ?? 'NOT FINISHED');
      } else {
        statuses.add('NOT FINISHED'); // Default status if not found
      }
    }

    moduleStatuses = statuses; // Store the fetched statuses
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.02),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modules',
                    style: GoogleFonts.montserrat(
                        fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Make module title larger
                                Text(
                                  modules[index],
                                  style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18, // Increased size for title
                                      color: Colors.blue),
                                ),
                                const SizedBox(height: 5),
                                // Smaller text for status, difficulty, and reward
                                Text(
                                  'Status: ${moduleStatuses[index]}',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14, // Decreased size
                                      color: Colors.black),
                                ),
                                Text(
                                  'Difficulty: EASY',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14, // Decreased size
                                      color: Colors.black),
                                ),
                                Text(
                                  'Reward: 500 XP',
                                  style: GoogleFonts.montserrat(
                                      fontSize: 14, // Decreased size
                                      color: Colors.lightBlue),
                                ),
                                const SizedBox(height: 5),
                                // Progress bar
                                LinearProgressIndicator(
                                  value: moduleCompleted[index] /
                                      moduleTotal[index],
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${moduleCompleted[index]} / ${moduleTotal[index]} completed',
                                  style: GoogleFonts.montserrat(),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigate to specific module
                              if (modules[index] == 'Reading Comprehension') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ReadingComprehensionLevels()),
                                );
                              } else if (modules[index] ==
                                  'Word Pronunciation') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WordProQuiz(
                                        moduleTitle: modules[index]),
                                  ),
                                );
                              } else if (modules[index] ==
                                  'Sentence Composition') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SentCompQuiz(),
                                  ),
                                );
                              } else if (modules[index] ==
                                  'Vocabulary Skills') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VocabSkillsQuiz(
                                        moduleTitle: modules[index]),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Modules'),
        BottomNavigationBarItem(
            icon: Icon(Icons.menu_book), label: 'Dictionary'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      currentIndex: 1,
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.lightBlue,
      backgroundColor: Colors.white,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 2:
            Navigator.pushNamed(
                context, '/dictionary_menu'); // Adjust as needed
            break;
          case 3:
            Navigator.pushNamed(context, '/profile_menu');
            break;
          case 4:
            Navigator.pushNamed(context, '/settings_menu');
            break;
        }
      },
    );
  }
}
