import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
            Text(
              'Hi, ${FirebaseAuth.instance.currentUser?.displayName ?? "User"}!',
              style: GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
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
                        style: GoogleFonts.montserrat(fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: IN PROGRESS',
                              style: TextStyle(color: Colors.grey)),
                          Text('Difficulty: EASY',
                              style: TextStyle(color: Colors.grey)),
                          Text('Reward: 500 XP',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
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
                      onTap: isDeleteMode
                          ? () {
                              setState(() {
                                selectedModules[index] =
                                    !selectedModules[index];
                              });
                            }
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
              onPressed: _deleteSelectedModules,
              backgroundColor: Colors.red,
              child: Icon(Icons.delete),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
