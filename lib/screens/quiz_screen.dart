import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/article_model.dart';

class QuizScreen extends StatefulWidget {
  final Article article;
  const QuizScreen({
    super.key,
    required this.article,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currQues = 1;

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
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFFB1A1FC), Color(0xFFB1A1FC)]),
          ),
          child: Column(
            children: [
            const SizedBox(height: 20.0,),
            SizedBox(
              height: 50.0,
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: (){

                        },
                        icon: const ImageIcon(AssetImage("assets/prev_date.png"))
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Question $_currQues",
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: (){

                        },
                        icon: const ImageIcon(AssetImage("assets/next_date.png"))
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 20.0,),
              ///image
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Image.network(
                    widget.article.urlToImage.toString(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // Show the image once it's loaded
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      ); // Show a loader while the image loads
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Error loading image',
                        style: TextStyle(color: Colors.red),
                      ); // Handle errors gracefully
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
          ]
              ),
        ),
      ),
    );
  }
}
