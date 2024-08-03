import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileMenu extends StatelessWidget {
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
            // Profile Circle
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    AssetImage('assets/i_read_pic.png'), // Add your image
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Juan Dela Cruz',
                style: GoogleFonts.montserrat(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Text(
                'Food and Bar Services (FBS)\nTanauan School of Fisheries',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),

            // Statistics Section
            Text('Statistics',
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  _buildStatCard('Ranking', '#1/100'),
                  _buildStatCard('XP Earned', '20,312'),
                  _buildStatCard('Modules Completed', '10/22'),
                  _buildStatCard('Level', '12'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavigationBar(context), // Ensure the nav bar is included
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      color: Colors.blue[800],
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(value,
                style:
                    GoogleFonts.montserrat(color: Colors.white, fontSize: 20)),
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
      currentIndex: 3,
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
          case 2:
            Navigator.pushNamed(context, '/addfield_menu');
            break;
          case 4:
            Navigator.pushNamed(context, '/settings_menu');
            break;
        }
      },
    );
  }
}
