import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../firestore/firestore_user.dart';

class AddFieldMenu extends StatefulWidget {
  @override
  _AddFieldMenuState createState() => _AddFieldMenuState();
}

class _AddFieldMenuState extends State<AddFieldMenu> {
  final List<String> fields = [
    'Reading Comprehension',
    'Sentence Composition',
    'Vocabulary Skills',
    'Word Pronunciation',
  ];

  void downloadModules(String field) async {
    try {
      var modulesSnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc(field)
          .get();

      if (modulesSnapshot.exists) {
        var modules = modulesSnapshot.data()?['modules'] as List<dynamic>;
        if (modules != null && modules.isNotEmpty) {
          // Create a list of module titles
          List<String> moduleTitles = [];
          for (var module in modules) {
            moduleTitles.add(module['title'] as String);
          }

          // Show dialog with module titles
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Download Modules'),
                content: Text(
                  'The modules you will download are:\n\n' +
                      moduleTitles.join('\n'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cancel action
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Handle download action here for the selected field
                      await (List<String> moduleTitles) async {
                        // Assuming you have the user ID
                        String userId = FirebaseAuth.instance.currentUser!.uid;
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .update({
                          'downloadedModules':
                              FieldValue.arrayUnion(moduleTitles),
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Modules downloaded successfully!')),
                        );
                      }(moduleTitles);
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Download'),
                  ),
                ],
              );
            },
          );
        } else {
          _showErrorDialog('No modules found for this field.');
        }
      } else {
        _showErrorDialog('Field not found.');
      }
    } catch (e) {
      _showErrorDialog('Error fetching modules: $e');
    }
  }

// Update _addDownloadedModules to accept specific modules
  Future<void> _addDownloadedModules(List<String> moduleTitles) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'downloadedModules': FieldValue.arrayUnion(moduleTitles),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Modules downloaded successfully!')),
    );
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
                Navigator.of(context).pop(); // Close the dialog
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose Your Field',
              style: GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: fields.map((field) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: () => downloadModules(field),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[500],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                      child: Text(
                        field,
                        style: GoogleFonts.montserrat(color: Colors.white),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
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
    currentIndex: 2,
    selectedItemColor: Colors.blue[900],
    unselectedItemColor: Colors.lightBlue,
    backgroundColor: Colors.white,
    onTap: (index) {
      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/home');
          break;
        case 1:
          Navigator.pushNamed(context, '/modules_menu');
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
