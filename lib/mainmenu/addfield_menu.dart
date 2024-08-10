import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modules_menu.dart';

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

  Map<String, List<String>> availableModules = {};
  List<String> downloadedModules = [];

  @override
  void initState() {
    super.initState();
    _loadDownloadedModules();
    _loadAvailableModules();
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
        });
      }
    } catch (e) {
      _showErrorDialog('Error loading downloaded modules: $e');
    }
  }

  Future<void> _loadAvailableModules() async {
    try {
      for (String field in fields) {
        var modulesSnapshot = await FirebaseFirestore.instance
            .collection('fields')
            .doc(field)
            .get();

        if (modulesSnapshot.exists) {
          var modules =
              modulesSnapshot.data()?['modules'] as List<dynamic>? ?? [];
          setState(() {
            availableModules[field] =
                modules.map((module) => module['title'] as String).toList();
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Error loading available modules: $e');
    }
  }

  void downloadModules(BuildContext context, String field) async {
    try {
      var modulesSnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc(field)
          .get();

      if (modulesSnapshot.exists) {
        var modules =
            modulesSnapshot.data()?['modules'] as List<dynamic>? ?? [];
        if (modules.isNotEmpty) {
          List<String> moduleTitles =
              modules.map((module) => module['title'] as String).toList();

          bool allDownloaded = moduleTitles
              .every((module) => downloadedModules.contains(module));

          if (allDownloaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("The field's modules are already downloaded!")),
            );
            return;
          }

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Download Modules'),
                content: Text('The modules you will download are:\n\n' +
                    moduleTitles.join('\n')),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await _addDownloadedModules(moduleTitles);
                      Navigator.of(context).pop();
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

  Future<void> _addDownloadedModules(List<String> moduleTitles) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'downloadedModules': FieldValue.arrayUnion(moduleTitles),
      });
      setState(() {
        downloadedModules.addAll(moduleTitles);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Modules downloaded successfully!')),
      );
    } catch (e) {
      _showErrorDialog('Error downloading modules: $e');
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
                  bool isClickable = availableModules[field]?.any(
                          (module) => !downloadedModules.contains(module)) ??
                      true;
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: isClickable
                          ? () => downloadModules(context, field)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isClickable ? Colors.blue[500] : Colors.grey,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModulesMenu(
                  onModulesUpdated: (updatedModules) {
                    setState(() {
                      downloadedModules = updatedModules;
                    });
                  },
                ),
              ),
            );
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
