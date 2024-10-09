import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../mainmenu/modules_menu.dart';

class WordProQuiz extends StatefulWidget {
  final String moduleTitle;

  const WordProQuiz({super.key, required this.moduleTitle});

  @override
  _WordProQuizState createState() => _WordProQuizState();
}

class _WordProQuizState extends State<WordProQuiz> {
  final FlutterTts flutterTts = FlutterTts();
  final SpeechToText speech = SpeechToText();
  final AudioRecorder _record = AudioRecorder();
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String recognizedText = '';
  bool isRecording = false;
  String feedbackMessage = '';
  IconData feedbackIcon = Icons.help; // Default icon for feedback

  late String userId;
  Timer? _speechTimer;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    fetchQuestions(); // Fetch questions on initialization
  }

  Future<void> fetchQuestions() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc('Word Pronunciation')
          .get();

      var data = snapshot.data();
      if (data != null && data['modules'] != null) {
        List<dynamic> modules = data['modules'];
        var module = modules.firstWhere(
          (module) => module['title'] == widget.moduleTitle,
          orElse: () => null,
        );

        if (module != null && module['questions'] != null) {
          questions = List<Map<String, dynamic>>.from(module['questions']);
          if (questions.isNotEmpty) {
            await speakQuestion();
          } else {
            setState(() {
              feedbackMessage = 'No questions found for this module.';
              feedbackIcon = Icons.error;
            });
          }
        } else {
          setState(() {
            feedbackMessage = 'Module not found.';
            feedbackIcon = Icons.error;
          });
        }
      } else {
        setState(() {
          feedbackMessage = 'No modules found.';
          feedbackIcon = Icons.error;
        });
      }
    } catch (e) {
      setState(() {
        feedbackMessage = 'Error fetching questions: $e';
        feedbackIcon = Icons.error;
      });
    }
  }

  Future<void> speakQuestion() async {
    await flutterTts.speak(questions[currentQuestionIndex]['question']);
  }

  Future<void> _startRecording() async {
    final hasPermission = await _record.hasPermission(); // Check permission
    if (hasPermission) {
      await _record.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
        ),
        path: '',
      );
      setState(() {
        recognizedText = ''; // Clear previous text
        isRecording = true;
        feedbackMessage = ''; // Clear feedback
      });

      // Start speech recognition
      if (await speech.initialize()) {
        speech.listen(onResult: (result) {
          setState(() {
            recognizedText =
                result.recognizedWords; // Update with recognized speech
          });
          _resetSpeechTimer(); // Reset the timer on speech
        });
      }
    } else {
      setState(() {
        feedbackMessage = 'Permission to record audio is not granted.';
        feedbackIcon = Icons.error;
      });
    }
  }

  void _resetSpeechTimer() {
    // Cancel previous timer if still running
    _speechTimer?.cancel();

    // Start a new timer to stop recording after a short delay
    _speechTimer = Timer(const Duration(seconds: 2), () async {
      await _stopRecording(); // Automatically stop recording
    });
  }

  Future<void> _stopRecording() async {
    await speech.stop(); // Stop speech recognition
    await _record.stop(); // Stop recording

    setState(() {
      isRecording = false;
    });

    // Check the answer immediately after stopping
    checkAnswer();
  }

  Future<void> checkAnswer() async {
    try {
      String correctAnswer = questions[currentQuestionIndex]['correctAnswer'];

      // Normalize both recognized text and correct answer for comparison
      if (_normalizeText(recognizedText) == _normalizeText(correctAnswer)) {
        setState(() {
          feedbackMessage = 'Correct!';
          feedbackIcon = Icons.check_circle; // Correct icon
        });
      } else {
        setState(() {
          feedbackMessage = 'Not quite correct.'; // Updated feedback message
          feedbackIcon = Icons.cancel; // Incorrect icon
        });
      }
    } catch (e) {
      setState(() {
        feedbackMessage = 'Error checking answer: $e';
        feedbackIcon = Icons.error;
      });
    }
  }

  String _normalizeText(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[.,!?;]'), '').trim();
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        recognizedText = '';
        feedbackMessage = '';
        feedbackIcon = Icons.help;
      });
      speakQuestion(); // Speak the next question
    } else {
      _showCompletionDialog(); // Show completion dialog for the last question
    }
  }

  Future<void> _showCompletionDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quiz Complete'),
          content: const Text(
              'You have completed all questions. Do you want to finish the quiz?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _record.stop(); // Stop recording
                await _updateUserProgress(); // Update user progress in Firebase

                // Navigate to ModulesMenu and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ModulesMenu(
                      onModulesUpdated: (modules) {
                        // Handle module updates here if needed
                      },
                    ),
                  ),
                  (route) => false, // Remove all previous routes
                );
              },
              child: const Text('Finish'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserProgress() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Update user's progress in the users collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(widget.moduleTitle)
        .set({
      'status': 'COMPLETED', // Set status to uppercase
      'lastQuestionIndex': questions.length - 1, // Add last question index
    }, SetOptions(merge: true));

    // Update user XP in the users collection
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'xp': FieldValue.increment(500), // Increment XP
    });

    // Add module to completedModules
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'completedModules': FieldValue.arrayUnion([widget.moduleTitle]),
    });
  }

  @override
  void dispose() {
    _record.dispose(); // Clean up the recorder
    _speechTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Pronunciation'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white, // Set text color to white
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        questions.isNotEmpty
                            ? questions[currentQuestionIndex]['question'] ??
                                'Loading...'
                            : 'Loading...',
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        recognizedText.isNotEmpty
                            ? recognizedText
                            : 'Say something...',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: isRecording ? _stopRecording : _startRecording,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(20),
                      ),
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (feedbackMessage.isNotEmpty)
                      Column(
                        children: [
                          Icon(
                            feedbackIcon,
                            color: feedbackIcon == Icons.check_circle
                                ? Colors.green
                                : feedbackIcon == Icons.cancel
                                    ? Colors.red
                                    : Colors.grey,
                            size: 60,
                          ),
                          Text(
                            feedbackMessage,
                            style: TextStyle(
                              color: feedbackIcon == Icons.check_circle
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 24,
                            ),
                          ),
                          if (feedbackIcon == Icons.check_circle)
                            ElevatedButton(
                              onPressed: _nextQuestion,
                              child: const Text('Next'),
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
