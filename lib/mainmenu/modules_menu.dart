import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../quiz/readcomp_quiz.dart';

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
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          downloadedModules =
              List<String>.from(userDoc.data()?['downloadedModules'] ?? []);
          selectedModules = List<bool>.filled(downloadedModules.length, false);
        });
      }
    } catch (e) {
      _showErrorDialog('Error loading downloaded modules: $e');
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
            'xp': FieldValue.increment(
                -500), // Adjust this value as per your logic
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
              'Deleting modules will remove all your progress. Are you sure?'),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReadCompQuiz(moduleTitle: moduleTitle),
                  ),
                );
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
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('progress')
                    .doc(
                        'Reading Comprehension') // Adjust this to your module name
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    String status = data['status'] ??
                        'NOT FINISHED'; // Ensure default is uppercase
                    return ListView.builder(
                      itemCount: downloadedModules.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: isDeleteMode ? 40 : 0,
                                  top: 10,
                                  bottom: 10),
                              child: Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text('Status: $status',
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
                              ),
                            ),
                            if (isDeleteMode)
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                child: Checkbox(
                                  value: selectedModules[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      selectedModules[index] = value!;
                                    });
                                  },
                                ),
                              ),
                          ],
                        );
                      },
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
