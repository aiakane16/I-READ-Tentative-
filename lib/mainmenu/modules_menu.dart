import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../quiz/readcomp_quiz.dart';
import '../quiz/wordpro_quiz.dart';

class ModulesMenu extends StatefulWidget {
  final Function(List<String>) onModulesUpdated;

  const ModulesMenu({super.key, required this.onModulesUpdated});

  @override
  _ModulesMenuState createState() => _ModulesMenuState();
}

class _ModulesMenuState extends State<ModulesMenu> {
  List<String> downloadedModules = [];
  List<bool> selectedModules = [];
  bool isDeleteMode = false;

  @override
  void initState() {
    super.initState();
    _loadDownloadedModules();
  }

  Future<void> _loadDownloadedModules() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    var userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      var modules =
          userDoc.data()?['downloadedModules'] as List<dynamic>? ?? [];
      setState(() {
        downloadedModules = List<String>.from(modules);
        selectedModules = List<bool>.filled(downloadedModules.length, false);
      });
    }
  }

  void _toggleDeleteMode() {
    setState(() {
      isDeleteMode = !isDeleteMode;
      if (!isDeleteMode) {
        selectedModules = List<bool>.filled(downloadedModules.length, false);
      }
    });
  }

  Future<void> _deleteSelectedModules() async {
    try {
      List<String> modulesToDelete = [];
      for (int i = 0; i < selectedModules.length; i++) {
        if (selectedModules[i]) {
          modulesToDelete.add(downloadedModules[i]);
        }
      }

      if (modulesToDelete.isNotEmpty) {
        String userId = FirebaseAuth.instance.currentUser!.uid;

        // Loop through each module to delete
        for (String module in modulesToDelete) {
          // Delete the corresponding progress document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('progress')
              .doc(module)
              .delete();

          // Optionally decrement the XP if needed (assuming 500 XP per module)
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'xp': FieldValue.increment(-500), // Adjust this value as needed
          });

          // Remove from completedModules array
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'completedModules': FieldValue.arrayRemove([module]),
          });
        }

        // Finally, remove the modules from downloadedModules
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'downloadedModules': FieldValue.arrayRemove(modulesToDelete),
        });

        setState(() {
          downloadedModules
              .removeWhere((module) => modulesToDelete.contains(module));
          selectedModules = List<bool>.filled(downloadedModules.length, false);
        });
        widget.onModulesUpdated(downloadedModules);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modules deleted successfully!')),
        );
      }
    } catch (e) {
      _showErrorDialog('Error deleting modules: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Check if the widget is still mounted

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

  void _confirmDeleteModules() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Warning'),
          content: const Text(
            'Deleting modules will remove all your progress. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel action
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedModules(); // Call deletion function
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showQuizConfirmationDialog(String moduleTitle) {
    // Determine the module type
    String moduleType =
        moduleTitle; // Assuming moduleTitle directly reflects the type

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Confirmation'),
          content: Text('You will play a quiz related to $moduleTitle.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel action
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate based on the module type
                if (moduleType == 'Reading Comprehension') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReadCompQuiz(moduleTitle: moduleTitle),
                    ),
                  );
                } else if (moduleType == 'Word Pronunciation') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WordProQuiz(moduleTitle: moduleTitle),
                    ),
                  );
                } else {
                  // Handle other module types or show an error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unknown module type.')),
                  );
                }
              },
              child: const Text('Play'),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Modules',
                  style:
                      GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _toggleDeleteMode,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: downloadedModules.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('progress')
                        .doc(downloadedModules[index])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (snapshot.hasData && snapshot.data != null) {
                        var moduleData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Card(
                          child: ListTile(
                            title: Text(
                              downloadedModules[index],
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                    'Status: ${moduleData['status'] ?? 'NOT FINISHED'}',
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
                              if (!isDeleteMode) {
                                _showQuizConfirmationDialog(
                                    downloadedModules[index]);
                              }
                            },
                          ),
                        );
                      }
                      return const Center(child: Text('No modules available.'));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: isDeleteMode
          ? Positioned(
              bottom: 60, // Position it above the bottom nav bar
              right: 16,
              child: FloatingActionButton(
                onPressed: _confirmDeleteModules,
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
            )
          : null,
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
