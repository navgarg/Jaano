import 'package:flutter/material.dart';
import 'package:jaano/constants.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/article_model.dart';

class QuizDialog extends StatefulWidget {
  final Article article;
  const QuizDialog({
    super.key,
    required this.article,
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
    await _speechToText.listen(
        onResult: _onSpeechResult,
        pauseFor: const Duration(seconds: 20),
        listenOptions: SpeechListenOptions(listenMode: ListenMode.dictation),
    );
    setState(() {

    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    print("words:");
    print(_wordsSpoken);
    if (_wordsSpoken == widget.article.questions![0].answer) {
      print("correct");
    }
    else{

      print("wrong");
    }
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
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9, // Limit max height
          maxWidth: MediaQuery.of(context).size.width * 0.9,   // Limit max width
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Quiz",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.article.questions?[0].question.toString() ?? " ", // todo: show both questions
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
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
              Padding(
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
      ),
    );
  }

}
