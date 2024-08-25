import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../quiz/readcomp_quiz.dart';

class ModulesMenu extends StatefulWidget {
  final Function(List<String>) onModulesUpdated;

  ModulesMenu({required this.onModulesUpdated});

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
          SnackBar(content: Text('Modules deleted successfully!')),
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
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
          title: Text('Warning'),
          content: Text(
            'Deleting modules will remove all your progress. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel action
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteSelectedModules(); // Call deletion function
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
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
          title: Text('Quiz Confirmation'),
          content: Text('You will play a quiz related to $moduleTitle.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel action
              },
              child: Text('Cancel'),
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
              child: Text('Play'),
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
                  'Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? "User"}!',
                  style:
                      GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isDeleteMode = !isDeleteMode;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: downloadedModules.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
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
                          SizedBox(
                              height: 10), // Space between title and status
                          Text('Status: IN PROGRESS',
                              style:
                                  GoogleFonts.montserrat(color: Colors.black)),
                          Text('Difficulty: EASY',
                              style:
                                  GoogleFonts.montserrat(color: Colors.black)),
                          Text('Reward: 500 XP',
                              style: GoogleFonts.montserrat(
                                  color: Colors.lightBlue)),
                        ],
                      ),
                      onTap: () {
                        _showQuizConfirmationDialog(downloadedModules[index]);
                      },
                      leading: isDeleteMode
                          ? Checkbox(
                              value: selectedModules[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedModules[index] = value!;
                                });
                              },
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: isDeleteMode
          ? FloatingActionButton(
              onPressed: _confirmDeleteModules,
              backgroundColor: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: [
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
