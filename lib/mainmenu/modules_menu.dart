import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_read_app/functions/readingcomp_levels.dart';
import '../quiz/readcomp_quiz.dart';
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
  bool isLoading = true; // To track loading state

  @override
  void initState() {
    super.initState();
    // No Firebase calls here to avoid accessing inherited widgets
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

      for (var fieldDoc in fieldDocs.docs) {
        var modulesData = fieldDoc.data()['modules'] as List<dynamic>? ?? [];
        fetchedModules
            .addAll(modulesData.map((module) => module['title'] as String));
      }

      // Fetch module statuses
      await _fetchModuleStatuses(fetchedModules);

      setState(() {
        modules = fetchedModules;
        isLoading = false; // Stop loading
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

      // Check if the module document exists and retrieve its status
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
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
                            title: Text(
                              modules[index],
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue), // Title in blue
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Text('Status: ${moduleStatuses[index]}',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.black)),
                                Text('Difficulty: EASY',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.black)),
                                Text('Reward: 500 XP',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.lightBlue)),
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
                context, '/dictionary_menu'); // Change this line
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
