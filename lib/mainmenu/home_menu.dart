import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeMenu extends StatefulWidget {
  final String username;

  HomeMenu({required this.username});

  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  String moduleStatus1 = 'NOT STARTED';
  String moduleStatus2 = 'NOT STARTED';

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
                children: [
                  _buildModuleCard(context, 'Basics of Subject Verb Agreement',
                      moduleStatus1, 'MEDIUM', '1,000 XP', (newValue) {
                    setState(() {
                      moduleStatus1 = newValue!;
                    });
                  }),
                  _buildModuleCard(
                      context,
                      'Singular and Plural Nouns (Part II)',
                      moduleStatus2,
                      'EASY',
                      '500 XP', (newValue) {
                    setState(() {
                      moduleStatus2 = newValue!;
                    });
                  }),
                ],
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

  Widget _buildModuleCard(BuildContext context, String title, String status,
      String difficulty, String reward, Function(String?)? onChanged) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/modules_menu');
      },
      child: Card(
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
              DropdownButton<String>(
                value: status,
                items: <String>['NOT STARTED', 'IN PROGRESS', 'COMPLETED']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.montserrat(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.black,
                isExpanded: true,
              ),
              SizedBox(height: 10),
              Text('Difficulty: $difficulty',
                  style: GoogleFonts.montserrat(color: Colors.blue)),
              Text('Reward: $reward',
                  style: GoogleFonts.montserrat(color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
