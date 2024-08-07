import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart'; // For FilteringTextInputFormatter
import 'package:intl/intl.dart'; // For date formatting
import '../mainmenu/home_menu.dart'; // Adjust import according to your structure
import 'package:firebase_core/firebase_core.dart';

class Register2Page extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  Register2Page({
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  _Register2PageState createState() => _Register2PageState();
}

class _Register2PageState extends State<Register2Page> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _strandController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<String> strands = [
    'Technical-Vocational-Livelihood (TVL)',
    'Humanities and Social Sciences (HUMSS)',
    'Accountancy, Business, & Management (ABM)',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBVfRzUF6fklJTckRC5n-G4WUKNy8qBj_o",
        authDomain: "i-read-tentative.firebaseapp.com",
        databaseURL:
            "https://i-read-tentative-default-rtdb.asia-southeast1.firebasedatabase.app",
        projectId: "i-read-tentative",
        storageBucket: "i-read-tentative.appspot.com",
        messagingSenderId: "211486070399",
        appId: "1:211486070399:web:2edb63d1d51d58a51c514a",
        measurementId: "G-64MRZZP3LD",
      ),
    );
  }

  Future<void> _selectBirthday(BuildContext context) async {
    DateTime now = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000, 1, 1),
      lastDate: now,
    );

    if (pickedDate != null) {
      if (pickedDate.year < 2000 || pickedDate.year > 2014) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a date between 2000 and 2014.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        String formattedDate = DateFormat('MM/dd/yyyy').format(pickedDate);
        setState(() {
          _birthdayController.text = formattedDate;
        });
      }
    }
  }

  void _confirmSignUp() {
    if (_fullNameController.text.isEmpty ||
        _strandController.text.isEmpty ||
        _birthdayController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    String message = '''
Please confirm the following information:
- Email: ${widget.emailController.text}
- Username: ${widget.usernameController.text}
- Password: ${widget.passwordController.text}
- Full Name: ${_fullNameController.text}
- Strand: ${_strandController.text}
- Birthday: ${_birthdayController.text}
- Address: ${_addressController.text}
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Sign Up'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog (No)
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => HomeMenu(
                          username: widget.usernameController.text,
                        )),
              );
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
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
            SizedBox(height: 10),
            Text(
              "Personify Yourself!",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Add in your personal details here',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            // Full Name Field
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(),
              ),
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            SizedBox(height: 20),

            // Strand ComboBox
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Strand',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _strandController.text.isEmpty
                      ? null
                      : _strandController.text,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  isExpanded: true,
                  items: strands.map((String strand) {
                    return DropdownMenuItem<String>(
                      value: strand,
                      child:
                          Text(strand, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _strandController.text = newValue!;
                    });
                  },
                  dropdownColor: Colors.blue[800]?.withOpacity(0.9),
                  style: GoogleFonts.montserrat(color: Colors.white),
                  hint: Text('Select Strand',
                      style: TextStyle(color: Colors.white54)),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Birthday Field
            GestureDetector(
              onTap: () => _selectBirthday(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday (MM/DD/YYYY)',
                    labelStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.blue[800]?.withOpacity(0.3),
                    border: OutlineInputBorder(),
                    hintText: 'MM/DD/YYYY...',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  style: GoogleFonts.montserrat(color: Colors.white),
                  readOnly: true,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Address Field
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(),
                hintText: 'Barangay, City...',
                hintStyle: TextStyle(color: Colors.white54),
              ),
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
            SizedBox(height: 20),

            // Sign Up Button
            ElevatedButton(
              onPressed: _confirmSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Sign Up',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
