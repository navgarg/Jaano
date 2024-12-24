import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jaano/constants.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/article_model.dart';
import 'QuizDialog.dart';

class ExpandedArticle extends StatefulWidget {
  final Article article;
  const ExpandedArticle({
    super.key,
    required this.article,
  });

  @override
  State<ExpandedArticle> createState() => _ExpandedArticleState();
}

class _ExpandedArticleState extends State<ExpandedArticle> {

  // final SpeechToText _speechToText = SpeechToText();
  // bool _speechEnabled = false;
  // String _wordsSpoken = "";

  final FlutterTts flutterTts = FlutterTts();


  @override
  void initState() {
    super.initState();
    // initSpeech();
    flutterTts.setLanguage('en-US'); //todo: set language after getting from device (?)
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.2);
  }

  void tts (String? content) async {
    await flutterTts.speak(content ?? "");

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
              /// Title
               Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  widget.article.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
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
              /// Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  widget.article.content.toString(),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 10),
              // Speech Status
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Text(
              //     _speechToText.isListening
              //         ? "Listening..."
              //         : _speechEnabled
              //         ? "Tap button to answer"
              //         : "Speech not available",
              //     style: const TextStyle(
              //       color: Colors.black54,
              //       fontSize: 16.0,
              //     ),
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              // const SizedBox(height: 10),
              // // Words Spoken
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: SingleChildScrollView(
              //     child: Text(
              //       _wordsSpoken,
              //       style: const TextStyle(
              //         fontSize: 16,
              //         fontStyle: FontStyle.italic,
              //       ),
              //       textAlign: TextAlign.justify,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 10),
              // Button
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => QuizDialog(article: widget.article),
                      );
                    },
                    child: const Text(
                      "Quiz",
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
