import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import '../quiz/readcomp_quiz.dart';

class HomeMenu extends StatefulWidget {
  const HomeMenu({super.key, required this.username});

  final String username;

  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  String username = '';
  int xp = 0;
  List<String> completedModules = [];
  List<Map<String, dynamic>> moduleTitles = [];

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
    _loadDownloadedModules();
  }

  Future<void> _fetchUserStats() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    final DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        username = data['username'] ?? 'User'; // Fetch username
        xp = data['xp'] ?? 0; // Use data instead of snapshot
        completedModules = List<String>.from(data['completedModules'] ?? []);
      });
    } else {
      print('User document does not exist');
    }
  }

  Future<void> _loadDownloadedModules() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var modules =
          userDoc.data()?['downloadedModules'] as List<dynamic>? ?? [];
      setState(() {
        moduleTitles = List<Map<String, dynamic>>.from(
            modules.map((module) => {'title': module}));
      });
    } else {
      print('User document does not exist');
      setState(() {
        moduleTitles = []; // Ensure it's empty
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getModuleStatus(
      List<String> moduleNames) async {
    List<Map<String, dynamic>> modulesWithStatus = [];

    for (String moduleName in moduleNames) {
      var moduleDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('progress')
          .doc(moduleName)
          .get();

      if (moduleDoc.exists) {
        var data = moduleDoc.data() as Map<String, dynamic>;
        modulesWithStatus.add({
          'title': moduleName,
          'status': data['status'] ?? 'NOT FINISHED', // Default status
          'difficulty': 'EASY', // Adjust as necessary
          'reward': '500 XP' // Adjust as necessary
        });
      } else {
        modulesWithStatus.add({
          'title': moduleName,
          'status': 'NOT FINISHED',
          'difficulty': 'EASY',
          'reward': '500 XP'
        });
      }
    }

    return modulesWithStatus;
  }

  Future<List<Map<String, dynamic>>> _getRandomModules() async {
    final random = Random();
    List<Map<String, dynamic>> modulesWithStatus = await _getModuleStatus(
      moduleTitles.map((e) => e['title'] as String).toList(),
    );

    if (modulesWithStatus.length <= 2) {
      return modulesWithStatus;
    } else {
      return (modulesWithStatus.toList()..shuffle(random)).sublist(0, 2);
    }
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
                Navigator.of(context).pop(); // Cancel action
              },
              child: Text('Cancel', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReadCompQuiz(moduleTitle: module['title']),
                  ),
                ); // Navigate to the quiz
              },
              child: Text('Play', style: GoogleFonts.montserrat()),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome, $username!',
                  style:
                      GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
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
                  Text('Ranking: #1/100',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                  Text('XP Earned: $xp',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                  Text('Modules Completed: ${completedModules.length}/22',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Recommendations',
                style:
                    GoogleFonts.montserrat(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _getRandomModules(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
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
                              module['status'],
                              module['difficulty'],
                              module['reward'],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const Center(child: Text('No modules available.'));
                },
              ),
            ),
          ],
        ),
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
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
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
            Navigator.pushNamed(context, '/addfield_menu');
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
