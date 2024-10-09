import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mainmenu/modules_menu.dart';
import '../pages/shortstory_page.dart';

class ReadCompQuiz extends StatefulWidget {
  final String moduleTitle;
  final List<String> uniqueIds; // Change this to a list

  const ReadCompQuiz({
    super.key,
    required this.moduleTitle,
    required this.uniqueIds, // Update to accept a list
  });

  @override
  _ReadCompQuizState createState() => _ReadCompQuizState();
}

class _ReadCompQuizState extends State<ReadCompQuiz> {
  int currentQuestionIndex = 0;
  int score = 0;
  int mistakes = 0;
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  bool isAnswerSelected = false;
  int selectedAnswerIndex = -1;
  String feedbackMessage = '';
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      String uniqueId = 'myoLYQD0ML1gWuSI0t1U'; // Hardcoded for testing
      String moduleTitle =
          'Easy'; // Adjust this to the correct difficulty level

      final querySnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc('Reading Comprehension')
          .collection(moduleTitle)
          .doc(uniqueId)
          .get();

      if (querySnapshot.exists) {
        final data = querySnapshot.data();

        if (data != null && data['modules'] != null) {
          var modulesData = data['modules'] as List<dynamic>;
          for (var module in modulesData) {
            if (module['questions'] != null) {
              var questionsData = module['questions'] as List<dynamic>;
              questions.addAll(List<Map<String, dynamic>>.from(questionsData));
            }
          }
        }
      }
    } catch (e) {
      _showErrorDialog(
          'Failed to load questions. Please try again.'); // Show error dialog
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showShortStory() {
    if (questions.isNotEmpty) {
      final shortStory = questions[currentQuestionIndex]['shortStory'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShortStoryPage(
            shortStory: shortStory,
            onComplete: () {
              setState(() {
                selectedAnswerIndex = -1;
                feedbackMessage = '';
                isCorrect = false;
                isAnswerSelected = false; // Ready for the quiz
              });
            },
          ),
        ),
      );
    }
  }

  void _submitAnswer() {
    final correctAnswer = questions[currentQuestionIndex]['correctAnswer'];

    if (selectedAnswerIndex != -1 &&
        questions[currentQuestionIndex]['options'][selectedAnswerIndex] ==
            correctAnswer) {
      setState(() {
        score++;
        feedbackMessage = "You are correct!";
        isCorrect = true;
      });
    } else {
      mistakes++;
      feedbackMessage = "Incorrect answer. Please try again.";
      isCorrect = false;
    }

    setState(() {
      isAnswerSelected = true; // Show feedback after submission
    });
  }

  void _nextQuestion() {
    if (isAnswerSelected && isCorrect) {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          isAnswerSelected = false; // Reset for the next question
          selectedAnswerIndex = -1; // Reset the selected answer
          feedbackMessage = ''; // Clear feedback
        });
        _showShortStory(); // Show the next short story
      } else {
        _showResults(); // Show results if it's the last question
      }
    }
  }

  Future<void> _showResults() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Update user's progress in the users collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(widget.moduleTitle)
        .set({
      'status': 'COMPLETED',
      'mistakes': mistakes,
      'time': 0,
    }, SetOptions(merge: true));

    // Update user XP in the users collection
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'xp': FieldValue.increment(500), // Increment XP
    });

    // Add module to completedModules
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'completedModules': FieldValue.arrayUnion([widget.moduleTitle]),
    });

    // Show results dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${widget.moduleTitle} Quiz Complete'),
          content: Text(
              'Score: $score/${questions.length}\nMistakes: $mistakes\nXP Earned: 500'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModulesMenu(
                      onModulesUpdated: (List<String> updatedModules) {
                        // Handle the updated modules here
                        // For example, you might want to refresh the displayed modules
                      },
                    ),
                  ),
                );
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context); // Return to previous screen
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.moduleTitle, style: GoogleFonts.montserrat()),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white, // Set text color to white
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : questions.isEmpty
                ? const Center(
                    child: Text('No questions available.',
                        style: TextStyle(fontSize: 18)))
                : _buildQuizContent(),
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = questions[currentQuestionIndex]['question'];
    final options = questions[currentQuestionIndex]['options'];

    return Container(
      decoration: const BoxDecoration(
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
            Text(
              question,
              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Column(
              children: options.map<Widget>((option) {
                bool isOptionDisabled = isAnswerSelected && isCorrect;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: isOptionDisabled
                        ? null // Disable button if answer is correct
                        : () {
                            setState(() {
                              selectedAnswerIndex = options.indexOf(option);
                              feedbackMessage = ''; // Reset feedback message
                              isAnswerSelected = false; // Allow resubmission
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedAnswerIndex == options.indexOf(option)
                              ? Colors.blue[700]
                              : Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      option,
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isAnswerSelected) {
                  if (isCorrect) {
                    _nextQuestion(); // Go to the next question if correct
                  } else {
                    // Allow resubmitting if incorrect
                    setState(() {
                      selectedAnswerIndex = -1; // Reset selection
                      feedbackMessage = ''; // Clear feedback
                      isAnswerSelected = false; // Reset
                    });
                  }
                } else {
                  _submitAnswer(); // Submit answer if not selected
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(isAnswerSelected
                  ? (isCorrect ? 'Next' : 'Submit')
                  : 'Submit'),
            ),
            const SizedBox(height: 20),
            if (isAnswerSelected)
              Column(
                children: [
                  Text(
                    feedbackMessage,
                    style: TextStyle(
                      color: isCorrect
                          ? const Color(0xFF00FF00)
                          : const Color(0xFFFF6666),
                      fontSize: 24,
                    ),
                  ),
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect
                        ? const Color(0xFF00FF00)
                        : const Color(0xFFFF6666),
                    size: 60,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
