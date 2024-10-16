import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../mainmenu/modules_menu.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final SpeechToText speech = SpeechToText();
  final AudioRecorder _record = AudioRecorder();
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  String recognizedText = '';
  bool isRecording = false;
  String feedbackMessage = '';
  IconData feedbackIcon = Icons.help;
  int attemptCounter = 0; // Track number of attempts
  bool showNextButton = false; // Control visibility of the Next button
  bool canRecord = true; // Control recording button availability
  Timer? _silenceTimer; // Timer for silence detection

  late String userId;

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
          .collection(widget.difficulty)
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
        setState(() {}); // Refresh UI without feedback
      }
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  Future<void> _speakQuestion() async {
    if (questions.isNotEmpty) {
      canRecord = false; // Disable recording button
      await flutterTts.speak(questions[currentQuestionIndex]['question']);
      flutterTts.setCompletionHandler(() {
        setState(() {
          canRecord = true; // Re-enable recording button after TTS completes
        });
      });
    }
  }

  // Update the _startRecording function
  Future<void> _startRecording() async {
    final hasPermission = await speech.initialize();
    if (hasPermission) {
      setState(() {
        recognizedText = 'Say something...';
        feedbackMessage = '';
        feedbackIcon = Icons.help;
        showNextButton = false;
        isRecording = true; // Set recording state
      });

      // Start listening
      speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });

          if (result.finalResult) {
            _stopRecording();
            checkAnswer(); // After recording, check the answer
          }
        },
        listenFor: Duration(seconds: 5),
        partialResults: true,
      );

      // Start silence timer
      _resetSilenceTimer();
    } else {
      setState(() {
        recognizedText = 'Speech recognition failed.';
        feedbackIcon = Icons.error;
      });
    }
  }

// Update the _stopRecording function
  Future<void> _stopRecording() async {
    await speech.stop(); // Stop listening

    if (isRecording) {
      setState(() {
        isRecording = false; // Update recording state
      });
    }

    // Check the answer after stopping the recording
    checkAnswer(); // Only call checkAnswer here
  }

  void _resetSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 5), () async {
      await _stopRecording(); // Stop recording after 5 seconds of silence
    });
  }

  Future<void> checkAnswer() async {
    String correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    bool isCorrect =
        _normalizeText(recognizedText) == _normalizeText(correctAnswer);

    if (isCorrect) {
      setState(() {
        feedbackMessage = 'Correct!';
        feedbackIcon = Icons.check_circle;
        attemptCounter = 0; // Reset counter on correct answer
        showNextButton = true; // Show next button
        canRecord = false; // Disable recording when correct
      });
    } else {
      // Increment attempt counter first
      attemptCounter++;

      if (attemptCounter < 3) {
        // First and second attempts
        setState(() {
          feedbackMessage = 'Not quite correct. Try again!';
          feedbackIcon = Icons.cancel;
          showNextButton = false; // Don't show Next button yet
          canRecord = true; // Allow recording again
        });
      } else if (attemptCounter == 3) {
        // Third attempt
        setState(() {
          feedbackMessage = 'Please try again'; // Message for the third attempt
          feedbackIcon = Icons.cancel; // Icon for the last attempt
          showNextButton = true; // Show Next button after third attempt
          canRecord = false; // Disable recording after three attempts
        });
      }
    }
  }

  String _normalizeText(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[.,!?;]'), '').trim();
  }

  Future<void> _nextQuestion() async {
    if (currentQuestionIndex < questions.length - 1 && showNextButton) {
      setState(() {
        currentQuestionIndex++;
        recognizedText =
            'Say something...'; // Reset recognized text for the next question
        feedbackMessage = ''; // Clear feedback for next question
        feedbackIcon = Icons.help; // Reset feedback for next question
        attemptCounter = 0; // Reset attempts for next question
        showNextButton = false; // Hide Next button for new question
        canRecord = true; // Re-enable recording for the next question
      });
      await _speakQuestion(); // Speak the next question
    } else {
      await _showCompletionDialog(); // Show completion dialog if all questions are answered
    }
  }

  Future<void> _showCompletionDialog() async {
    if (!mounted) return; // Ensure widget is still mounted
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Quiz Complete'),
          content: const Text(
              'You have completed all questions. Do you want to finish the quiz?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                await _updateUserProgress();

                // Navigate to ModulesMenu safely
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => ModulesMenu(
                      onModulesUpdated: (modules) {},
                    ),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Finish'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
          ],
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
        // Update existing document
        print('Updating existing document: $difficultyDocId');
        await docRef.set({
          'status': 'COMPLETED', // Mark as completed
          'attempts': FieldValue.increment(1) // Increment attempts
        }, SetOptions(merge: true));
      } else {
        // Create new document if it doesn't exist
        print('Creating new document: $difficultyDocId');
        await docRef.set({
          'status': 'COMPLETED', // Initial status
          'attempts': 1 // Initial attempt count
        });
      }
      print('Document updated successfully.');
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  @override
  void dispose() {
    _record.dispose();
    _silenceTimer?.cancel(); // Cancel the silence timer
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
                    style: TextStyle(
                      color: feedbackIcon == Icons.check_circle
                          ? Colors.green
                          : Colors.red,
                      fontSize: 20, // Adjusted font size for feedback
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Update the UI button in the build method
                ElevatedButton(
                  onPressed:
                      canRecord && !showNextButton ? _startRecording : null,
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
                // Show "Next" button only on correct answer or after three incorrect attempts
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
