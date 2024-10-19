import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DictionaryMenu extends StatelessWidget {
  const DictionaryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Example dictionary entries
    final Map<String, String> dictionaryEntries = {
      'Reading Comprehension': 'Understanding and interpreting what you read.',
      'Sentence Composition': 'Constructing sentences correctly.',
      'Vocabulary Skills': 'Improving the range of words you use.',
      'Word Pronunciation': 'Correctly saying words aloud.',
    };

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        return true; // Exit the app when back is pressed
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[900]!, Colors.blue[700]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Dictionary',
                  style: GoogleFonts.montserrat(
                    fontSize: width * 0.06,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: dictionaryEntries.entries.map((entry) {
                    return Card(
                      color: Colors.white, // White background for cards
                      child: ListTile(
                        title: Text(
                          entry.key,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue, // Blue color for module name
                          ),
                        ),
                        subtitle: Text(
                          entry.value,
                          style: GoogleFonts.montserrat(
                              color:
                                  Colors.black), // Black color for description
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
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Modules'),
        BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Dictionary'), // Dictionary icon
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
