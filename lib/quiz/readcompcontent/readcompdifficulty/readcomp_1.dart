import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:i_read_app/models/answer.dart';
import 'package:i_read_app/models/module.dart';
import 'package:i_read_app/models/question.dart';
import 'package:i_read_app/services/api.dart';
import 'package:i_read_app/services/storage.dart';
import '../../../mainmenu/modules_menu.dart';

class ReadCompQuiz extends StatefulWidget {
  final String moduleTitle;
  final String difficulty;
  final List<String> uniqueIds;

  const ReadCompQuiz({
    super.key,
    required this.moduleTitle,
    required this.difficulty,
    required this.uniqueIds,
  });

  @override
  _ReadCompQuizState createState() => _ReadCompQuizState();
}

class _ReadCompQuizState extends State<ReadCompQuiz> {
  int score = 0;
  int mistakes = 0;
  List<Question> questions = [];
  bool isLoading = true;
  bool isAnswerSubmitted = false;
  bool hasEarnedXP = false; // Track if XP has been earned
  int selectedAnswerIndex = -1; // Track the selected answer index
  StorageService storageService = StorageService();
  ApiService apiService = ApiService();
  List<Answer> answers = [];
  String moduleId = '';
  String moduleTitle = '';
  bool isAnswerSelected = false;
  String feedbackMessage = '';

  Question? currentQuestion;
  int currentQuestionIndex = 0;
  late Timer _timer;
  int _remainingTime = 300; // 5 minutes for each question
  bool isCalculatingResults = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      List<Module> modules = await storageService.getModules();
      Module module =
          modules.where((element) => element.difficulty == widget.difficulty && element.category == 'Reading Comprehension' ).last;
      List<Question> moduleQuestions = module.questionsPerModule;

      setState(() {
        questions = moduleQuestions;
        isLoading = false;
        moduleId = module.id;
        moduleTitle = module.title;
      });
    } catch (e) {
      _showErrorDialog('Failed to load questions. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _remainingTime = 300; // Reset timer for every question
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        if (mounted) {
          setState(() {
            _remainingTime--;
          });
        }
      } else {
        _timer.cancel();
        _nextQuestion(); // Automatically submit when time runs out
      }
    });
  }

  void _nextQuestion() {
    Question currentQuestion = questions[currentQuestionIndex];
    Answer answer = Answer(
        questionId: currentQuestion.id,
        answer: currentQuestion.choices[selectedAnswerIndex].text);
    answers.add(answer);

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswerSelected = false; // Reset for the next question
        selectedAnswerIndex = -1; // Reset the selected answer
        feedbackMessage = ''; // Clear feedback
      });
    } else if (currentQuestionIndex == questions.length - 1) {
      _showResults(); // Only show results if it's the last question
    } else {
      _showResults(); // Only show results if it's the last question
    }
  }

  Future<void> _showResults() async {
    Map<String, dynamic> response = await apiService.postSubmitModuleAnswer(moduleId, answers);
    List<Module>? modules = await apiService.getModules();

    if (modules != null && modules.isNotEmpty) {
      await storageService.storeModules(modules);
    }
    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.blue,
          title: Text(
            '$moduleTitle Quiz Complete',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          content: Text(
            'Score: ${response['score']}/${questions.length}\nMistakes: ${questions.length - response['score']}\nXP Earned: ${response['points_gained']}',
            style: GoogleFonts.montserrat(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pop(context); // Return to modules menu
              },
              child: Text(
                'Done',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
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
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quiz', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          actions: [
            Icon(Icons.access_time),
            const SizedBox(width: 10),
            Text(
              '${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity, // Fill the entire screen
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF003366), Color(0xFF0052CC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : questions.isEmpty
                  ? const Center(child: Text('No questions available.'))
                  : isCalculatingResults
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          // Make the content scrollable
                          child: _buildQuizContent(),
                        ),
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = questions[currentQuestionIndex].text;
    final options = questions[currentQuestionIndex].choices;

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
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content vertically
          children: [
            Text(
              question,
              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Column(
              children: options.map<Widget>((option) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedAnswerIndex = options.indexOf(option);
                        feedbackMessage = ''; // Reset feedback message
                        isAnswerSelected = false; // Allow resubmission
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          selectedAnswerIndex == options.indexOf(option)
                              ? Colors.orange // Color for selected options
                              : Colors.blue[700], // Updated button color
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      option.text,
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedAnswerIndex != -1) {
                  _nextQuestion(); // Allow moving to the next question after feedback is shown
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(150, 40),
              ),
              child: Text(
                'Next', // Change button text based on selection
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
