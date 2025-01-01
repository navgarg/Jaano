import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/constants.dart';
import 'package:jaano/screens/quiz_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/article_model.dart';

class ExpandedArticleScreen extends StatefulWidget {
  final Article article;
  const ExpandedArticleScreen({
    super.key,
    required this.article,
  });

  @override
  State<ExpandedArticleScreen> createState() => _ExpandedArticleScreenState();
}

class _ExpandedArticleScreenState extends State<ExpandedArticleScreen> {

  // final SpeechToText _speechToText = SpeechToText();
  // bool _speechEnabled = false;
  // String _wordsSpoken = "";

  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  int start = 0;
  int end = 0;


  @override
  void initState() {
    super.initState();
    // initSpeech();
    flutterTts.setLanguage('en-US'); //todo: set language after getting from device (?)
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.2);
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
      });
    });

    flutterTts.setProgressHandler(
            (String text, int startOffset, int endOffset, String word) {
          setState(() {
            start = startOffset;
            end = endOffset;
          });
        });

  }

  void ttsSpeak (String? content) async {
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(content ?? "");

  }

  Future<void> ttsStop () async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => isSpeaking = false);
  }


  @override
  void dispose() {
    flutterTts.stop();  // Stops speech when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9585D2),
        body: SafeArea(
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
                      child: Stack(
                        children: [
                          // Shimmer effect
                          Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 200.0,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          // Actual image
                          Image.network(
                              widget.article.urlToImage.toString(),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child; // Show the image once it's loaded
                                }
                                return Container(); // Keep showing the shimmer effect while loading
                              },
                      // child: Image.network(
                      //   widget.article.urlToImage.toString(),
                      //   loadingBuilder: (context, child, loadingProgress) {
                      //     if (loadingProgress == null) {
                      //       return child; // Show the image once it's loaded
                      //     }
                      //     return Center(
                      //       child: CircularProgressIndicator(
                      //         value: loadingProgress.expectedTotalBytes != null
                      //             ? loadingProgress.cumulativeBytesLoaded /
                      //             (loadingProgress.expectedTotalBytes ?? 1)
                      //             : null,
                      //       ),
                      //     ); // Show a loader while the image loads
                      //   },
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.red),
                          ); // Handle errors gracefully
                        },
                      ),
                      ],
                    ),
                  ),
        ),
                  const SizedBox(height: 30),
                  /// Date and Source
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat("dd/MM/yyyy").format(DateTime.parse(widget.article.publishedAt ?? DateTime.now().toString()))),
                        Text(widget.article.source.name),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: widget.article.content != null && start != 0
                                  ? widget.article.content!.substring(0, start)
                                  : "",
                              style: const TextStyle(
                                color: Color(0xFF090438),
                                fontSize: 24.0,
                              ),
                          ),
                          TextSpan(
                              text: widget.article.content != null
                                  ? widget.article.content!.substring(start, end)
                                  : "",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                          TextSpan(
                              text: widget.article.content != null ? widget.article.content!.substring(end) : "",
                              style: const TextStyle(
                                color: Color(0xFF090438),
                                fontSize: 24.0,
                              )
                          ),
                        ]
                        ),
                    )
                    // child: Text(
                    //   widget.article.content.toString(),
                    //   style: const TextStyle(
                    //       fontSize: 24.0,
                    //     color: Color(0xFF090438),
                    //   ),
                    //   textAlign: TextAlign.left,
                    // ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: IconButton(
                        icon: Image.asset("assets/tech/quiz.png"),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => QuizScreen(article: widget.article)),
                          );
                          // showDialog(
                          //   context: context,
                          //   builder: (context) => (article: widget.article),
                          // );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            isSpeaking ? ttsStop() : ttsSpeak(widget.article.content);
          },
        backgroundColor: const Color(0xFF090438),
        child: Icon(
          isSpeaking ? Icons.pause_circle : Icons.play_circle,
          color: Colors.white,
          size: 40.0,
        ),
          ),
        );
  }

}
