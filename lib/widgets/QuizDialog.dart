import 'package:flutter/material.dart';
import 'package:jaano/constants.dart';
import 'package:speech_to_text/speech_to_text.dart';

class QuizDialog extends StatefulWidget {
  final String title;
  final String content;
  const QuizDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> {

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async{
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {

    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {

    });
  }

  void _onSpeechResult(result) async {
    ///update UI with words that were transcribed.
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: FractionallySizedBox(
        widthFactor: 0.95,
        heightFactor: 0.7, // Adjustable height
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            // Content
            Flexible(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Text(
                    widget.content,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Speech Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _speechToText.isListening
                    ? "Listening..."
                    : _speechEnabled
                    ? "Tap button to answer"
                    : "Speech not available",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            // Words Spoken
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Text(
                    _wordsSpoken,
                    style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Button
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    _speechToText.isListening
                        ? _stopListening()
                        : _startListening();
                  },
                  child: Text(
                    _speechToText.isListening ? "Stop Listening" : "Start Listening",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
