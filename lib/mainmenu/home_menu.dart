import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_read_app/quiz/vocabskill_quiz.dart';
import 'dart:math';
import '../quiz/readcomp_quiz.dart';
import '../quiz/sentcomp_quiz.dart';
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
  List<Map<String, dynamic>> allModules = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAllModules();
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
      nickname = userDoc.data()?['username'] ?? 'User';
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
            'status': 'NOT FINISHED'
          });
        }
      }

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
        module['status'] = data['status'] ?? 'NOT FINISHED';
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getRandomModules() async {
    final random = Random();
    if (allModules.isEmpty) return [];
    return (allModules.toList()..shuffle(random))
        .take(2)
        .toList(); // Changed back to 2
  }

  void _navigateToQuiz(Map<String, dynamic> module) {
    String moduleTitle = module['title'];
    if (moduleTitle == 'Reading Comprehension') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReadCompQuiz(
            moduleTitle: moduleTitle,
            uniqueIds: const [],
          ),
        ),
      );
    } else if (moduleTitle == 'Word Pronunciation') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordProQuiz(moduleTitle: moduleTitle),
        ),
      );
    } else if (moduleTitle == 'Sentence Composition') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SentCompQuiz(),
        ),
      );
    } else if (moduleTitle == 'Vocabulary Skills') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VocabSkillsQuiz(moduleTitle: moduleTitle),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unknown module type.')),
      );
    }
  }

  void _showChangelog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          title: Text(
            'Changelog',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(
                  'October 09, 2024',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Beta 1.1 (0.3.1)',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'What\'s New?',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '- Mobile optimization for main interfaces.\n'
                  '- Updated interface for Reading Comprehension Module.\n'
                  '- Added Changelogs.',
                  style:
                      GoogleFonts.montserrat(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Bug Fixes',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '- Backend improvements.\n'
                  '- Fixed some files going to the wrong interface.\n'
                  '- Fixed Edit Profile.\n'
                  '- More minor bug fixes.',
                  style:
                      GoogleFonts.montserrat(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Coming soon in future builds!',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '- Updated interface for Sentence Composition Module.\n'
                  '- Adding Help feature for how-to-guide.\n'
                  '- Ranking feature.\n'
                  '- Adding module contents and quizzes, replacing the sample ones.\n'
                  '- Experience points mechanics.\n'
                  '- More backend improvements.\n'
                  '- Dictionary feature.\n'
                  '- Mobile optimization for quizzes\' interface.\n'
                  '- ...and more!',
                  style:
                      GoogleFonts.montserrat(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'October 07, 2024',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Beta 1.0 (0.3.0)',
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'What\'s New?',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '- Initial Release!',
                  style:
                      GoogleFonts.montserrat(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelp() {
    // Help dialog or screen can be shown here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
            nickname = data['username'] ?? 'User';
            xp = data['xp'] ?? 0;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[900]!, Colors.blue[700]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.02),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Welcome, $nickname!',
                        style: GoogleFonts.montserrat(
                          fontSize: width * 0.06,
                          color: Colors.white,
                        ),
                      ),
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
                          fontSize: width * 0.05, color: Colors.white)),
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
                        } else if (snapshot.hasData &&
                            snapshot.data!.isNotEmpty) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var module = snapshot.data![index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        module['title'],
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Status: ${module['status']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Difficulty: ${module['difficulty']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Reward: ${module['reward']}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 14,
                                          color: Colors.lightBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      LinearProgressIndicator(
                                        value: module['progress'] ?? 0.0,
                                        backgroundColor: Colors.grey[300],
                                        color: Colors.green,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${module['completed']} / ${module['total']} completed',
                                        style: GoogleFonts.montserrat(),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _navigateToQuiz(module),
                                ),
                              );
                            },
                          );
                        }
                        return const Center(
                            child: Text('No modules available.'));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Changelog and Help buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15), // Increased padding
                        ),
                        onPressed: _showChangelog,
                        child: Text(
                          "Changelog",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15), // Increased padding
                        ),
                        onPressed: _showHelp,
                        child: Text(
                          "Help",
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
