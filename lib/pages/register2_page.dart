import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../functions/form_data.dart';
import '../mainmenu/home_menu.dart';

class PersonalInfoPage extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const PersonalInfoPage({
    super.key,
    required this.emailController,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
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
    // Load values from FormData
    _fullNameController.text = FormData().fullName;
    _strandController.text = FormData().strand;
    _birthdayController.text = FormData().birthday;
    _addressController.text = FormData().address;

    // Add listeners to save input in real-time
    _fullNameController.addListener(() {
      FormData().fullName = _fullNameController.text;
    });
    _strandController.addListener(() {
      FormData().strand = _strandController.text;
    });
    _birthdayController.addListener(() {
      FormData().birthday = _birthdayController.text;
    });
    _addressController.addListener(() {
      FormData().address = _addressController.text;
    });
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
          const SnackBar(
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

  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Your Information'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Email: ${widget.emailController.text}'),
                Text('Username: ${widget.usernameController.text}'),
                Text('Password: ${widget.passwordController.text}'),
                Text('Full Name: ${_fullNameController.text}'),
                Text('Strand: ${_strandController.text}'),
                Text('Birthday: ${_birthdayController.text}'),
                Text('Address: ${_addressController.text}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                _confirmSignUp();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmSignUp() async {
    // Check for empty fields
    if (_fullNameController.text.isEmpty ||
        _strandController.text.isEmpty ||
        _birthdayController.text.isEmpty ||
        _addressController.text.isEmpty ||
        widget.emailController.text.isEmpty ||
        widget.usernameController.text.isEmpty ||
        widget.passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.emailController.text,
        password: widget.passwordController.text,
      );

      String uid = userCredential.user!.uid;

      // Initialize user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': _fullNameController.text, // Save full name
        'username': widget.usernameController.text, // Save username
        'strand': _strandController.text, // Save strand
        'birthday': _birthdayController.text, // Save birthday
        'address': _addressController.text, // Save address
        'email': widget.emailController.text,
        'downloadedModules': [], // Start with empty
        'completedModules': [], // Start with empty
        'xp': 0,
      });

      // Fetch default user data
      DocumentSnapshot defaultUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc('User ID') // Replace with your actual default user ID
          .get();

      Map<String, dynamic>? defaultData =
          defaultUserDoc.data() as Map<String, dynamic>?;

      if (defaultData != null) {
        // Only copy the default module progress
        await _initializeModuleProgress(uid, 'Reading Comprehension');
        await _initializeModuleProgress(uid, 'Word Pronunciation');
        await _initializeModuleProgress(uid, 'Sentence Composition');
        await _initializeModuleProgress(uid, 'Vocabulary Skills');
      }

      // Navigate to Home Menu
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeMenu(),
        ),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _initializeModuleProgress(String uid, String moduleName) async {
    var moduleData = await FirebaseFirestore.instance
        .collection('users')
        .doc('User ID') // Default user
        .collection('progress')
        .doc(moduleName)
        .get();

    if (moduleData.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('progress')
          .doc(moduleName)
          .set(moduleData.data()!);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
        padding: EdgeInsets.symmetric(
            horizontal: width * 0.05, vertical: height * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Personify Yourself!",
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Add in your personal details here',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Full Name Field
            TextFormField(
              controller: _fullNameController,
              maxLength: 50,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                hintText: 'Enter Full Name here...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.person, color: Colors.white),
              ),
              style: GoogleFonts.montserrat(color: Colors.white),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\d')),
              ],
              buildCounter: (context,
                  {required currentLength, maxLength, required isFocused}) {
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Strand ComboBox with Icon
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Strand',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _strandController.text.isEmpty
                      ? null
                      : _strandController.text,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  isExpanded: true,
                  items: strands.map((String strand) {
                    return DropdownMenuItem<String>(
                      value: strand,
                      child: Row(
                        children: [
                          const Icon(Icons.school, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(strand,
                              style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _strandController.text = newValue!;
                    });
                  },
                  dropdownColor: Colors.blue[800]?.withOpacity(0.9),
                  style: GoogleFonts.montserrat(color: Colors.white),
                  hint: const Text('Select Strand',
                      style: TextStyle(color: Colors.white54)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Birthday Field
            GestureDetector(
              onTap: () => _selectBirthday(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday (MM/DD/YYYY)',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.blue[800]?.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue[800]!),
                    ),
                    hintText: 'MM/DD/YYYY...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon:
                        const Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  style: GoogleFonts.montserrat(color: Colors.white),
                  readOnly: true,
                  buildCounter: (context,
                      {required currentLength, maxLength, required isFocused}) {
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Address Field
            TextFormField(
              controller: _addressController,
              maxLength: 100,
              decoration: InputDecoration(
                labelText: 'Address',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.blue[800]?.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                hintText: 'Barangay, City...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.location_on, color: Colors.white),
              ),
              style: GoogleFonts.montserrat(color: Colors.white),
              buildCounter: (context,
                  {required currentLength, maxLength, required isFocused}) {
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Sign Up Button
            ElevatedButton(
              onPressed: _showConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                'Sign Up',
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Terms and Conditions
            RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontSize: 12,
                ),
                children: [
                  const TextSpan(text: 'By signing up, you agree to\n'),
                  TextSpan(
                    text: 'I-READ\'s Terms of Service and Privacy Policy.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Define action for tapping the terms link
                      },
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Full Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: LinearProgressIndicator(
                value: 1.0, // Full progress for the last page
                backgroundColor: Colors.grey[400],
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
