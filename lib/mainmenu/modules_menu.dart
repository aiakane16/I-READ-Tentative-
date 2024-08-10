import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../firestore/firestore_readcomp.dart';
import '../firestore/firestore_sentcomp.dart';
import '../firestore/firestore_vocabskill.dart';
import '../firestore/firestore_wordpro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModulesMenu extends StatefulWidget {
  @override
  _ModulesMenuState createState() => _ModulesMenuState();
}

class _ModulesMenuState extends State<ModulesMenu> {
  final FirestoreReadComp _readComp = FirestoreReadComp();
  final FirestoreSentComp _sentComp = FirestoreSentComp();
  final FirestoreVocabSkill _vocabSkill = FirestoreVocabSkill();
  final FirestoreWordPro _wordPro = FirestoreWordPro();

  List<Map<String, dynamic>> downloadedModules = [];
  List<bool> selectedModules = [];
  bool isDeleteMode = false; // Track whether delete mode is active

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
      var modules = userDoc.data()?['downloadedModules'] as List<dynamic>;
      setState(() {
        downloadedModules = List<Map<String, dynamic>>.from(
            modules.map((module) => {'title': module}));
        selectedModules = List<bool>.filled(
            downloadedModules.length, false); // Initialize selection state
      });
    }
  }

  void _toggleDeleteMode() {
    setState(() {
      isDeleteMode = !isDeleteMode;
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Do you want to delete the selected modules? Please note that all your progress will be gone if you continue.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                _deleteSelectedModules();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteModule(String moduleToDelete) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'downloadedModules': FieldValue.arrayRemove([moduleToDelete]),
    });

    // Update local state
    setState(() {
      downloadedModules
          .removeWhere((module) => module['title'] == moduleToDelete);
      selectedModules.removeAt(downloadedModules
          .indexWhere((module) => module['title'] == moduleToDelete));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Module deleted successfully!')),
    );
  }

  void _deleteSelectedModules() async {
    for (int i = 0; i < downloadedModules.length; i++) {
      if (selectedModules[i]) {
        await _deleteModule(downloadedModules[i]['title']);
      }
    }

    setState(() {
      isDeleteMode = false; // Exit delete mode after deletion
    });
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
                  'Hi, Juan!',
                  style:
                      GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: _toggleDeleteMode,
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              'Available Modules:',
              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: downloadedModules.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                downloadedModules[index]['title'],
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text('Status: IN PROGRESS',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.black)),
                              Text('Difficulty: EASY',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.black)),
                              Text('Reward: 500 XP',
                                  style: GoogleFonts.montserrat(
                                      color: Colors
                                          .lightBlue)), // Light blue reward
                            ],
                          ),
                          if (isDeleteMode)
                            Checkbox(
                              value: selectedModules[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedModules[index] = value!;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isDeleteMode
          ? FloatingActionButton(
              onPressed: _showConfirmationDialog,
              backgroundColor: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            )
          : null,
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
