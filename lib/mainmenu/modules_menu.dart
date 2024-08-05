import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModulesMenu extends StatelessWidget {
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
              'Hi, Juan!',
              style: GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'Available Modules:',
              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildModuleCard(
                    context,
                    'Singular and Plural Nouns (Part I)',
                    'IN PROGRESS',
                    'EASY',
                    '1000 XP',
                  ),
                  _buildModuleCard(
                    context,
                    'Basics of Subject Verb Agreement',
                    'NOT STARTED',
                    'MEDIUM',
                    '1000 XP',
                  ),
                  _buildModuleCard(
                    context,
                    'Singular and Plural Nouns (Part II)',
                    'IN PROGRESS',
                    'EASY',
                    '500 XP',
                  ),
                  _buildModuleCard(
                    context,
                    'Advanced Synonyms and Antonyms',
                    'LOCKED',
                    'HARD',
                    '2000 XP',
                  ),
                ],
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
