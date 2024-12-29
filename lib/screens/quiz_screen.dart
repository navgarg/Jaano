import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jaano/services/riverpod_providers.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/article_model.dart';

class QuizScreen extends ConsumerWidget {
  final Article article;

  const QuizScreen({
    super.key,
    required this.article,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("in build for quiz");
    final currQues = ref.watch(questionIndexProvider);
    final speechState = ref.watch(speechStateProvider);
    final speechNotifier = ref.read(speechStateProvider.notifier);

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

                          if (currQues == 2) ref.read(questionIndexProvider.notifier).state = 1;
                        },
                        // icon: _currQues == 1 ? const ImageIcon(AssetImage("assets/prev_date_greyed.png"))
                        // : const ImageIcon(AssetImage("assets/prev_date.png"))
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
                        "Question $currQues",
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
                          if (currQues == 1) ref.read(questionIndexProvider.notifier).state = 2;
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
                    article.urlToImage.toString(),
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
                  article.questions?[currQues-1].question.toString() ?? " ",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 10),
              // Speech Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                    speechState.isListening
                      ? "Listening..."
                      : speechState.speechEnabled
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
                    speechState.wordsSpoken,
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
                      speechState.isListening
                          ? speechNotifier.stopListening(article)
                          : speechNotifier.startListening();
                    },
                    child: Text(
                      speechState.isListening ? "Stop Listening" : "Start Listening",
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
