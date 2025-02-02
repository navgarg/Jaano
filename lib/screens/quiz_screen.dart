import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jaano/services/riverpod_providers.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../constants.dart';
import '../models/article_model.dart';
import '../widgets/placeholders/shimmer_img_placeholder.dart';
import '../widgets/quiz_answer.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Article article;
  final int index;

  const QuizScreen({
    super.key,
    required this.index,
    required this.article,
  });
  @override
  ConsumerState<QuizScreen> createState() => _QuizScreen();
}

class _QuizScreen extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();
  bool isProcessingDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Initialize speech when the widget is built
    Future.microtask(() {
      ref.read(speechStateProvider.notifier).initSpeech();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleProcessingState(BuildContext context) {
    final speechState = ref.read(speechStateProvider);

    if (speechState.isProcessing) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          showProcessingDialog(context, ref, widget.index);
        }
      });
    } else {
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    ref.listen(answerProvider, (previous, next) {
      if (next.isLoading && !isProcessingDialogOpen) {
        isProcessingDialogOpen = true; // Mark dialog as open
        Future.delayed(Duration.zero, () {
          if (mounted) showProcessingDialog(context, ref, widget.index);
        });
      } else if (next.hasValue) {
        Future.delayed(Duration.zero, () {
          if (mounted) {
            if (isProcessingDialogOpen) {
              // Ensure processing dialog is closed first
              Navigator.of(context, rootNavigator: true).pop();
              isProcessingDialogOpen = false; // Reset flag
            }
            showAnswerDialog(context, next.value!.feedback, widget.index);
          }
        });
      }
    });

    print("in build for quiz");
    final currQues = ref.watch(questionIndexProvider);
    final speechState = ref.watch(speechStateProvider);
    final speechNotifier = ref.read(speechStateProvider.notifier);

    if (speechState.isListening) {
      _controller.repeat(reverse: true);
    } else {
      _controller.reset();
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage(expdBgImgs[widget.index]), //todo: update bg img
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20.0,
                  ),
                  SizedBox(
                    height: 50.0,
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              onPressed: () {
                                if (currQues == 2) {
                                  ref.read(questionIndexProvider.notifier).state =
                                      1;
                                }
                              },
                              icon: currQues == 1
                                  ? const ImageIcon(
                                      AssetImage("assets/prev_date_grey.png"))
                                  : const ImageIcon(
                                      AssetImage("assets/prev_date.png"))),
                          // icon: const ImageIcon(
                          //     AssetImage("assets/prev_date.png"))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Color(bgColors[widget.index]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Question $currQues",
                              style: const TextStyle(
                                color: Color(0xFF090438),
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              onPressed: () {
                                if (currQues == 1) {
                                  ref.read(questionIndexProvider.notifier).state =
                                      2;
                                }
                              },
                              icon: currQues == 2
                                  ? const ImageIcon(
                                      AssetImage("assets/next_date_grey.png"))
                                  : const ImageIcon(
                                      AssetImage("assets/next_date.png"))),
                          // icon: const ImageIcon(
                          //     AssetImage("assets/next_date.png"))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
            
                  ///image
                  ShimmerImgPlaceholder(article: widget.article),
                  const SizedBox(height: 30),
            
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      widget.article.questions?[currQues - 1].question
                              .toString() ??
                          " ",
                      style: const TextStyle(
                        color: Color(0xFF090438),
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 20),
            
                  /// Words Spoken
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(bgColors[widget.index]),
                              Color(bgColors[widget.index])
                            ]),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              speechState.wordsSpoken,
                              style: const TextStyle(
                                color: Color(0xFF090438),
                                fontSize: 18.0,
                                letterSpacing: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Speech Status
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
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
                  ),
                  const SizedBox(height: 10),
                  // Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          speechState.isListening
                              ? speechNotifier.stopListening(
                                  widget.article, currQues - 1)
                              : speechNotifier.startListening();
                        },
                        child: Stack(alignment: Alignment.center, children: [
                          // Ripple effect using animated scale
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Container(
                                width: 100 + _controller.value * 50,
                                height: 100 + _controller.value * 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: speechState.isListening
                                      ? Color(bgColors[widget.index])
                                          .withOpacity(1 - _controller.value)
                                      : Colors.transparent,
                                ),
                              );
                            },
                          ),
                          // Second wave
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Container(
                                width: 150 + _controller.value * 50,
                                height: 150 + _controller.value * 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: speechState.isListening
                                      ? Color(bgColors[widget.index]).withOpacity(
                                          0.5 - _controller.value / 2)
                                      : Colors.transparent,
                                ),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Color(bgColors[widget.index]),
                              borderRadius:
                                  BorderRadius.circular(40), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Color(bgColors[widget.index])
                                      .withOpacity(0.6), // Shadow color
                                  blurRadius: 15, // Spread of the shadow
                                  spreadRadius: 5, // Intensity of the glow effect
                                  offset: const Offset(0, 0), // Centered shadow
                                ),
                              ],
                              border: Border.all(
                                color: Colors.black, // Highlighted border color
                                width: 1, // Border thickness
                              ),
                            ),
                            child: ImageIcon(
                              AssetImage(speechIcons[widget.index]),
                              size: 35,
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ]),
          ),
        ]),
      ),
    );
  }
}
