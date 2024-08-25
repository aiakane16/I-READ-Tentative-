import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added FirebaseAuth import
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReadCompQuiz extends StatefulWidget {
  final String moduleTitle;

  ReadCompQuiz({required this.moduleTitle});

  @override
  _ReadCompQuizState createState() => _ReadCompQuizState();
}

class _ReadCompQuizState extends State<ReadCompQuiz> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> questions = [];
  String selectedOption = '';
  String feedbackMessage = '';
  bool isCorrect = false;
  bool isLoading = true;
  bool isLastQuestion = false;
  int mistakes = 0;
  int startTime = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    startTime = DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> loadQuestions() async {
    try {
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.moduleTitle)
          .get();

      if (snapshot.exists) {
        final modules = snapshot.get('modules') as List<dynamic>;

        if (modules.isNotEmpty) {
          setState(() {
            questions =
                List<Map<String, dynamic>>.from(modules[0]['questions']);
            isLoading = false;
          });
        } else {
          print('No modules found in the snapshot.');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print('Snapshot data: ${snapshot.data()}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkAnswer() {
    if (selectedOption == questions[currentQuestionIndex]['correctAnswer']) {
      setState(() {
        feedbackMessage = 'Correct!';
        isCorrect = true;
        isLastQuestion = currentQuestionIndex == questions.length - 1;
      });
    } else {
      setState(() {
        feedbackMessage = 'Incorrect. Please try again.';
        isCorrect = false;
        mistakes += 1; // Increment mistakes on wrong answer
      });
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = '';
        feedbackMessage = '';
        isCorrect = false;
      });
    } else {
      _showQuizSummary();
    }
  }

  Future<void> _updateQuizResults(int timeTaken, int xpEarned) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final moduleRef =
        FirebaseFirestore.instance.collection('fields').doc(widget.moduleTitle);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      final moduleSnapshot = await transaction.get(moduleRef);

      if (userSnapshot.exists && moduleSnapshot.exists) {
        int currentXP = userSnapshot['xp'] ?? 0;
        transaction.update(userRef, {
          'xp': currentXP + xpEarned,
        });

        transaction.update(moduleRef, {
          'time': timeTaken,
          'mistakes': mistakes,
          'status': 'Finished',
        });
      }
    });
  }

  void _showQuizSummary() {
    int timeTaken = DateTime.now().millisecondsSinceEpoch - startTime;
    int xpEarned = (questions.length - mistakes) * 10;

    _updateQuizResults(timeTaken, xpEarned);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${widget.moduleTitle} Quiz Summary',
              style: GoogleFonts.montserrat()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${timeTaken ~/ 1000} seconds',
                  style: GoogleFonts.montserrat()),
              Text('Mistakes: $mistakes', style: GoogleFonts.montserrat()),
              Text('XP Earned: $xpEarned', style: GoogleFonts.montserrat()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the summary dialog
                Navigator.pushReplacementNamed(context,
                    '/modules_menu'); // Navigate back to the modules_menu
              },
              child: Text('Done', style: GoogleFonts.montserrat()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.moduleTitle, style: GoogleFonts.montserrat()),
          backgroundColor: Colors.blue[900],
        ),
        body: Center(child: CircularProgressIndicator()), // Loading indicator
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.moduleTitle, style: GoogleFonts.montserrat()),
          backgroundColor: Colors.blue[900],
        ),
        body: Center(
          child: Text(
            'No questions available.',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF003366), Color(0xFF0052CC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF00)),
              ),
              SizedBox(height: 20),
              Text(
                questions[currentQuestionIndex]['shortStory'],
                style:
                    GoogleFonts.montserrat(fontSize: 14, color: Colors.white),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20),
              Text(
                questions[currentQuestionIndex]['question'],
                style:
                    GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 20),
              Column(
                children: questions[currentQuestionIndex]['options']
                    .map<Widget>((option) {
                  return ListTile(
                    title: Text(
                      option,
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                    leading: Radio<String>(
                      value: option,
                      groupValue: selectedOption,
                      onChanged: (String? value) {
                        setState(() {
                          selectedOption = value!;
                          feedbackMessage = ''; // Clear previous feedback
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedOption.isNotEmpty
                    ? () {
                        if (isCorrect) {
                          _nextQuestion();
                        } else {
                          _checkAnswer();
                        }
                      }
                    : null,
                child: Text(isLastQuestion && isCorrect
                    ? 'Finish'
                    : (isCorrect ? 'Next' : 'Submit')),
              ),
              if (feedbackMessage.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Text(
                        feedbackMessage,
                        style: TextStyle(
                          color:
                              isCorrect ? Color(0xFF00FF00) : Color(0xFFFF6666),
                          fontSize: 24,
                        ),
                      ),
                      Icon(
                        isCorrect
                            ? FontAwesomeIcons.check
                            : FontAwesomeIcons.times,
                        color:
                            isCorrect ? Color(0xFF00FF00) : Color(0xFFFF6666),
                        size: 60,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
