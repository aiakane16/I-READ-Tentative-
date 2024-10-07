import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../quiz/readcomp_quiz.dart';
import '../quiz/wordpro_quiz.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key});

  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  String nickname = '';
  int xp = 0;
  List<String> completedModules = [];
  List<Map<String, dynamic>> allModules = []; // Store all modules

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAllModules(); // Load all available modules
  }

  Stream<DocumentSnapshot> _fetchUserStats() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  Future<void> _loadUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      nickname = userDoc.data()?['fullName'] ?? 'User';
      xp = userDoc.data()?['xp'] ?? 0;
      completedModules =
          List<String>.from(userDoc.data()?['completedModules'] ?? []);
    } else {
      print('User document does not exist');
    }
  }

  Future<void> _loadAllModules() async {
    try {
      var fieldsSnapshot =
          await FirebaseFirestore.instance.collection('fields').get();
      List<Map<String, dynamic>> loadedModules = [];

      for (var fieldDoc in fieldsSnapshot.docs) {
        var modulesData = fieldDoc.data()['modules'] as List<dynamic>? ?? [];
        for (var module in modulesData) {
          loadedModules.add({
            'title': module['title'] ?? 'Unknown Module',
            'difficulty': module['difficulty'] ?? 'EASY',
            'reward': module['reward'] ?? '500 XP',
            'status': 'NOT FINISHED' // Default status
          });
        }
      }

      // Now fetch the status for each module
      await _fetchModuleStatuses(loadedModules);

      setState(() {
        allModules = loadedModules;
      });
    } catch (e) {
      print('Error loading all modules: $e');
    }
  }

  Future<void> _fetchModuleStatuses(List<Map<String, dynamic>> modules) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    for (var module in modules) {
      var moduleDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('progress')
          .doc(module['title'])
          .get();

      if (moduleDoc.exists) {
        var data = moduleDoc.data() as Map<String, dynamic>;
        module['status'] = data['status'] ?? 'NOT FINISHED'; // Update status
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getRandomModules() async {
    final random = Random();
    if (allModules.isEmpty) return []; // Return empty list if no modules

    // Shuffle and select 2 random modules
    return (allModules.toList()..shuffle(random)).take(2).toList();
  }

  void _showModuleDialog(Map<String, dynamic> module) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Confirmation'),
          content: Text('You will play a quiz related to ${module['title']}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToQuiz(module);
              },
              child: Text('Play', style: GoogleFonts.montserrat()),
            ),
          ],
        );
      },
    );
  }

  void _navigateToQuiz(Map<String, dynamic> module) {
    String moduleTitle = module['title'];
    if (moduleTitle == 'Reading Comprehension') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadCompQuiz(moduleTitle: moduleTitle),
        ),
      );
    } else if (moduleTitle == 'Word Pronunciation') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordProQuiz(moduleTitle: moduleTitle),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown module type.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: _fetchUserStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            nickname =
                data['fullName'] ?? 'User'; // Fetch full name or nickname
            xp = data['xp'] ?? 0;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[900]!, Colors.blue[700]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome, $nickname!',
                        style: GoogleFonts.montserrat(
                            fontSize: 24, color: Colors.white),
                      ),
                      const Icon(Icons.person, color: Colors.white, size: 30),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(15),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ranking: #1/4',
                            style: GoogleFonts.montserrat(color: Colors.white)),
                        Text('XP Earned: $xp',
                            style: GoogleFonts.montserrat(color: Colors.white)),
                        Text('Modules Completed: ${completedModules.length}/4',
                            style: GoogleFonts.montserrat(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Recommendations',
                      style: GoogleFonts.montserrat(
                          fontSize: 18, color: Colors.white)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _getRandomModules(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (snapshot.hasData) {
                          return ListView(
                            children: snapshot.data!.map((module) {
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => _showModuleDialog(module),
                                  child: _buildModuleCard(
                                    context,
                                    module['title'],
                                    module['status'] ?? 'Not Finished',
                                    module['difficulty'] ?? 'EASY',
                                    module['reward'] ?? '500 XP',
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }
                        return const Center(
                            child: Text('No modules available.'));
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('User document does not exist.'));
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildModuleCard(BuildContext context, String title, String status,
      String difficulty, String reward) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text('Status: $status',
                style: GoogleFonts.montserrat(color: Colors.black)),
            Text('Difficulty: $difficulty',
                style: GoogleFonts.montserrat(color: Colors.black)),
            Text('Reward: $reward',
                style: GoogleFonts.montserrat(color: Colors.blue)),
          ],
        ),
      ),
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
      currentIndex: 0,
      selectedItemColor: Colors.blue[900],
      unselectedItemColor: Colors.lightBlue,
      backgroundColor: Colors.white,
      onTap: (index) {
        switch (index) {
          case 1:
            Navigator.pushNamed(context, '/modules_menu');
            break;
          case 2:
            Navigator.pushNamed(context, '/dictionary_menu');
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
