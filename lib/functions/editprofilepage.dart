import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  String? _selectedStrand; // To store the selected strand

  // List of strands
  final List<String> strands = [
    'Technical-Vocational-Livelihood (TVL)',
    'Humanities and Social Sciences (HUMSS)',
    'Accountancy, Business, & Management (ABM)',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data when the page initializes
  }

  Future<void> _fetchUserData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      setState(() {
        _usernameController.text =
            userSnapshot.get('username') ?? ''; // Fetch nickname
        _fullNameController.text =
            userSnapshot.get('fullName') ?? ''; // Fetch full name
        _selectedStrand =
            userSnapshot.get('strand') ?? strands[0]; // Default to first strand
      });
    } else {
      print('User document does not exist');
    }
  }

  Future<void> _updateProfile() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'fullName': _fullNameController.text,
      'strand': _selectedStrand,
      'username': _usernameController.text,
    });

    Navigator.of(context).pop(); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            TextField(
              controller: _fullNameController,
              style: const TextStyle(
                  color: Colors.white), // Change text color to white
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(
                    color: Colors.white), // Change label color to white
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _usernameController,
              style: const TextStyle(
                  color: Colors.white), // Change text color to white
              decoration: const InputDecoration(
                labelText: 'Nickname',
                labelStyle: TextStyle(
                    color: Colors.white), // Change label color to white
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedStrand,
              decoration: const InputDecoration(
                labelText: 'Strand',
                labelStyle: TextStyle(
                    color: Colors.white), // Change label color to white
                border: OutlineInputBorder(),
              ),
              items: strands.map((String strand) {
                return DropdownMenuItem<String>(
                  value: strand,
                  child: Text(strand,
                      style: const TextStyle(
                          color: Colors
                              .white)), // Change dropdown item text color to white
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStrand = newValue;
                });
              },
              dropdownColor:
                  Colors.blue[700], // Change dropdown background color
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile, // Change button text to white
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
              child: Text('Save Changes',
                  style: GoogleFonts.montserrat(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
