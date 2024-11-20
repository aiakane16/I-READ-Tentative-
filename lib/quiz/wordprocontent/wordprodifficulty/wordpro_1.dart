import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../mainmenu/modules_menu.dart';

class WordProQuiz extends StatefulWidget {
  final String moduleTitle;
  final List<String> uniqueIds;
  final String difficulty;

  const WordProQuiz({
    super.key,
    required this.moduleTitle,
    required this.uniqueIds,
    required this.difficulty,
  });

  @override
  _WordProQuizState createState() => _WordProQuizState();
}

class _WordProQuizState extends State<WordProQuiz> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String recognizedText = '';
  bool isListening = false;
  String feedbackMessage = '';
  IconData feedbackIcon = Icons.help;
  int attemptCounter = 0;
  bool showNextButton = false;
  late String userId;
  Timer? _silenceTimer;
  bool isSpeaking = false; // Track TTS speaking state

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      String uniqueId = 'sPB0TBLavMJimWriirGr';
      final querySnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc('Word Pronunciation')
          .collection('Easy')
          .doc(uniqueId)
          .get();

      if (querySnapshot.exists) {
        final data = querySnapshot.data();
        if (data != null && data['modules'] != null) {
          var modulesData = data['modules'] as List<dynamic>;

          for (var module in modulesData) {
            var questionsData = module['questions'] as List<dynamic>;
            for (var questionData in questionsData) {
              questions.add({
                'question': questionData['question'],
                'correctAnswer': questionData['correctAnswer'],
              });
            }
          }
        }
      }
      if (questions.isNotEmpty) {
        await _speakQuestion();
        setState(() {});
      }
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  Future<void> _speakQuestion() async {
    if (questions.isNotEmpty) {
      setState(() {
        isSpeaking = true; // Set speaking state
      });
      await flutterTts.speak(questions[currentQuestionIndex]['question']);
      flutterTts.setCompletionHandler(() {
        setState(() {
          isSpeaking = false; // Reset speaking state
        });
      });
    }
  }

  void startListening() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isDenied) {
        setState(() {
          recognizedText = 'Microphone permission denied.';
        });
        return;
      }
    }

    if (!isListening && !isSpeaking) {
      // Check if TTS is speaking
      bool available = await speech.initialize();
      if (available) {
        setState(() {
          recognizedText = 'Listening...';
          feedbackMessage = '';
          feedbackIcon = Icons.help;
          showNextButton = false;
          isListening = true;
        });

        // Start listening and the countdown immediately
        speech.listen(onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        });

        // Start the countdown timer to check the speech after 5 seconds
        _silenceTimer?.cancel(); // Cancel any existing timer
        _silenceTimer = Timer(Duration(seconds: 5), () {
          speech.stop();
          isListening = false;
          checkAnswer(recognizedText); // Check the answer after 5 seconds
        });
      } else {
        setState(() {
          recognizedText = 'Speech recognition not available.';
        });
      }
    }
  }

  Future<void> checkAnswer(String recognizedText) async {
    String correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    int accuracy = _calculateAccuracy(recognizedText, correctAnswer);

    if (accuracy >= 90) {
      // Change threshold to 90%
      setState(() {
        feedbackMessage = 'You are $accuracy% accurate!';
        feedbackIcon = Icons.check_circle;
        attemptCounter = 0;
        showNextButton = true;
      });
    } else {
      attemptCounter++;
      setState(() {
        feedbackMessage = 'You are $accuracy% accurate!';
        feedbackIcon = Icons.cancel;
        showNextButton = attemptCounter >= 3;
      });
    }
  }

  int _calculateAccuracy(String recognizedText, String correctAnswer) {
    // Calculate accuracy based on word similarity
    int correctCount = 0;
    List<String> recognizedWords = recognizedText.split(' ');
    List<String> correctWords = correctAnswer.split(' ');

    for (var word in recognizedWords) {
      if (correctWords.contains(word)) {
        correctCount++;
      }
    }

    // Calculate percentage accuracy
    int accuracy = ((correctCount / correctWords.length) * 100).round();
    return accuracy > 100 ? 100 : accuracy; // Limit accuracy to 100%
  }

  Future<void> _nextQuestion() async {
    if (currentQuestionIndex < questions.length - 1 && showNextButton) {
      setState(() {
        currentQuestionIndex++;
        recognizedText = 'Say something...';
        feedbackMessage = '';
        feedbackIcon = Icons.help;
        attemptCounter = 0;
        showNextButton = false;
      });
      await _speakQuestion();
    } else {
      await _showCompletionDialog();
    }
  }

  Future<void> _showCompletionDialog() async {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Quiz Complete',
              style: TextStyle(color: Colors.white)),
          content: const Text(
              'You have completed all questions. Do you want to finish the quiz?',
              style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _updateUserProgress();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ModulesMenu(
                      onModulesUpdated: (modules) {},
                    ),
                  ),
                  (route) => false,
                );
              },
              child:
                  const Text('Finish', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
          backgroundColor: Colors.blue[900],
        );
      },
    );
  }

  Future<void> _updateUserProgress() async {
    String difficultyDocId = '$userId-Word Pronunciation-${widget.difficulty}';

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('progress')
        .doc(widget.moduleTitle)
        .collection('difficulty')
        .doc(difficultyDocId);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.set({
          'status': 'COMPLETED',
          'attempts': FieldValue.increment(1),
        }, SetOptions(merge: true));
      } else {
        await docRef.set({
          'status': 'COMPLETED',
          'attempts': 1,
        });
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  @override
  void dispose() {
    speech.stop();
    _silenceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Pronunciation', style: GoogleFonts.montserrat()),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
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
                Text(
                  questions.isNotEmpty
                      ? questions[currentQuestionIndex]['question']
                      : 'Loading question...',
                  style:
                      GoogleFonts.montserrat(fontSize: 24, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    recognizedText.isNotEmpty
                        ? recognizedText
                        : 'Say something...',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                if (feedbackMessage.isNotEmpty) ...[
                  Icon(
                    feedbackIcon,
                    color: feedbackIcon == Icons.check_circle
                        ? Colors.green
                        : Colors.red,
                    size: 60,
                  ),
                  Text(
                    feedbackMessage,
                    style: GoogleFonts.montserrat(
                      color: feedbackIcon == Icons.check_circle
                          ? Colors.green
                          : Colors.red,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                ElevatedButton(
                  onPressed: !isListening && !showNextButton && !isSpeaking
                      ? startListening
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Icon(
                    isListening ? Icons.stop : Icons.mic,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                if (showNextButton) ...[
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
