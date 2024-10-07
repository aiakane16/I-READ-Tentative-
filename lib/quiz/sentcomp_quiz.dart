import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';

class SentCompQuiz extends StatefulWidget {
  const SentCompQuiz({super.key});

  @override
  _SentenceCompositionQuizState createState() =>
      _SentenceCompositionQuizState();
}

class _SentenceCompositionQuizState extends State<SentCompQuiz> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  List<String> options = [];
  String correctAnswer = '';
  List<String> userSelections = [];
  String sentenceWithBlanks = '';
  bool hasAnsweredCurrentQuestion = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc('Sentence Composition')
          .get();

      var modules = snapshot.data()?['modules'] as List<dynamic>? ?? [];
      if (modules.isNotEmpty) {
        var questionsData = modules[0]['questions'] as List<dynamic>? ?? [];
        for (var question in questionsData) {
          var blanks =
              question['blanks']; // Fetch the sentence with blanks as a string
          var correctAnswer =
              question['correctAnswer']; // Correct answer as a string
          var options = List<String>.from(
              question['options'].map((option) => option.toString()));

          questions.add({
            'blanks': blanks,
            'correctAnswer': correctAnswer,
            'options': options,
          });
        }

        if (questions.isNotEmpty) {
          setState(() {
            currentQuestionIndex = 0;
            this.correctAnswer =
                questions[currentQuestionIndex]['correctAnswer'].trim();
            options = List.from(questions[currentQuestionIndex]['options']);
            sentenceWithBlanks = questions[currentQuestionIndex]['blanks'];
            userSelections =
                List.filled(sentenceWithBlanks.split(' ').length, '');
          });
        }
      }
    } catch (e) {
      print('Error fetching questions: $e');
    }
  }

  void handleOptionClick(String selectedWord) {
    setState(() {
      for (int i = 0; i < userSelections.length; i++) {
        if (userSelections[i].isEmpty &&
            sentenceWithBlanks.split(' ')[i] == '___') {
          userSelections[i] = selectedWord; // Fill the first blank
          options.remove(selectedWord); // Remove the selected option
          hasAnsweredCurrentQuestion =
              true; // Mark current question as answered
          break; // Exit after replacing the first empty spot
        }
      }
    });
  }

  void toggleSelection(int index) {
    setState(() {
      if (userSelections[index].isNotEmpty) {
        options.add(userSelections[index]); // Re-add the word to options
        userSelections[index] = ''; // Reset to empty
      }
    });
  }

  void checkAnswer() {
    String userAnswer = '';
    List<String> wordsInBlanks = sentenceWithBlanks.split(' ');

    for (int i = 0; i < wordsInBlanks.length; i++) {
      if (wordsInBlanks[i] == '___') {
        userAnswer += userSelections[i] + ' '; // Add user selection for blank
      } else {
        userAnswer += wordsInBlanks[i] + ' '; // Add the original word
      }
    }

    userAnswer = userAnswer.trim(); // Clean up any trailing spaces

    // Check if the constructed answer matches the correct answer
    if (userAnswer.toLowerCase() == correctAnswer.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Correct!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect, try again!')),
      );
    }
  }

  Future<void> submitQuiz() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Update user's progress in the users collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc('Sentence Composition')
        .set({
      'status': 'COMPLETED', // Set status to uppercase
      // Add other relevant fields as needed
    }, SetOptions(merge: true));

    // Update user XP in the users collection
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'xp': FieldValue.increment(500), // Increment XP in the correct place
    });

    // Add module to completedModules
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'completedModules': FieldValue.arrayUnion(
          ['Sentence Composition']), // Adjust as necessary
    });

    // Show completion message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz Completed!')),
    );

    // Navigate to modules_menu
    Navigator.pushReplacementNamed(
        context, '/modules_menu'); // Update this to your actual route
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        this.correctAnswer =
            questions[currentQuestionIndex]['correctAnswer'].trim();
        options = List.from(questions[currentQuestionIndex]['options']);
        sentenceWithBlanks = questions[currentQuestionIndex]['blanks'];
        userSelections = List.filled(sentenceWithBlanks.split(' ').length, '');
        hasAnsweredCurrentQuestion = false; // Reset for the next question
      });
    } else {
      // If there are no more questions, submit the quiz
      submitQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    List<String> wordsInBlanks = sentenceWithBlanks.split(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sentence Composition Quiz'),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[900]!, Colors.blue[700]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the sentence with blanks
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                    children: List<InlineSpan>.generate(wordsInBlanks.length,
                        (index) {
                      String word = wordsInBlanks[index];
                      if (word == '___') {
                        return TextSpan(
                          text: userSelections[index].isEmpty
                              ? '___ '
                              : '${userSelections[index]} ', // Show blank or filled word
                          style: const TextStyle(color: Colors.white),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              toggleSelection(
                                  index); // Allow user to toggle selection
                            },
                        );
                      } else {
                        return TextSpan(
                          text: '$word ', // Show the word
                          style: const TextStyle(color: Colors.white),
                        );
                      }
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                // Display the given words as options
                Wrap(
                  spacing: 8,
                  children: options.map((option) {
                    return ElevatedButton(
                      onPressed: () {
                        handleOptionClick(option);
                      },
                      child: Text(option),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: hasAnsweredCurrentQuestion
                      ? () {
                          checkAnswer();
                          if (currentQuestionIndex < questions.length - 1) {
                            goToNextQuestion();
                          } else {
                            submitQuiz(); // Submit quiz if it's the last question
                          }
                        }
                      : null, // Enable if answered
                  child: Text(currentQuestionIndex < questions.length - 1
                      ? 'Next'
                      : 'Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
