import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFieldMenu extends StatelessWidget {
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
            Text(
              'Choose Your Field',
              style: GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            _buildFieldButton(context, 'Vocabulary Skills', Colors.lightBlue),
            _buildFieldButton(
                context, 'Reading Comprehension', Colors.red[200]),
            _buildFieldButton(context, 'Word Pronunciation',
                Colors.green), // Changed to Green
            _buildFieldButton(context, 'Sentence Composition',
                Colors.yellow), // Changed to Yellow
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildFieldButton(BuildContext context, String title, Color? color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          // Action for button press
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Set the button color
          padding:
              EdgeInsets.symmetric(vertical: 24), // Increase vertical padding
          minimumSize: Size(double.infinity, 60), // Make button height larger
        ),
        child: Text(
          title,
          style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white), // Bold font style
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
}
