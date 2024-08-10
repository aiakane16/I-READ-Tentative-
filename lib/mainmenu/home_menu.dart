import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class HomeMenu extends StatefulWidget {
  final String username;

  HomeMenu({required this.username});

  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  List<Map<String, dynamic>> moduleTitles = [];

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
      var modules = userDoc.data()?['downloadedModules'] as List<dynamic> ?? [];
      setState(() {
        moduleTitles = List<Map<String, dynamic>>.from(modules.map((module) =>
            {'title': module, 'difficulty': 'EASY', 'questions': 11}));
      });
    }
  }

  List<Map<String, dynamic>> _getRandomModules() {
    final random = Random();
    if (moduleTitles.length <= 2) {
      return moduleTitles;
    } else {
      return (moduleTitles.toList()..shuffle(random)).sublist(0, 2);
    }
  }

  void _showModuleDialog(Map<String, dynamic> module) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(module['title']),
          content: Text(
            'Difficulty: ${module['difficulty']}\n\n'
            'This module includes ${module['questions']} items of questions related to ${module['title']}.\n'
            'Are you ready?',
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
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the module questions screen here
              },
              child: Text('Ready!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> selectedModules = _getRandomModules();

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
                  'Welcome!',
                  style:
                      GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
                ),
                Icon(Icons.person, color: Colors.white, size: 30),
              ],
            ),
            SizedBox(height: 10),
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
                  Text('XP Earned: 1000',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                  Text('Level: 12',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Recommendations',
                style:
                    GoogleFonts.montserrat(fontSize: 18, color: Colors.white)),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: selectedModules.map((module) {
                  return GestureDetector(
                    onTap: () => _showModuleDialog(module),
                    child: _buildModuleCard(context, module['title'],
                        'NOT STARTED', module['difficulty'], '1,000 XP'),
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

  Widget _buildModuleCard(BuildContext context, String title, String status,
      String difficulty, String reward) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10),
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
            SizedBox(height: 10),
            Text('Status: $status',
                style: GoogleFonts.montserrat(color: Colors.black)),
            Text('Difficulty: $difficulty',
                style: GoogleFonts.montserrat(color: Colors.blue)),
            Text('Reward: $reward',
                style: GoogleFonts.montserrat(color: Colors.blue)),
          ],
        ),
      ),
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
