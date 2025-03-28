import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/constants.dart';
import 'package:jaano/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaano/screens/quiz_screen.dart';
import 'package:jaano/widgets/category_header.dart';
import 'package:jaano/widgets/navbar/bottom_navbar.dart';
import 'package:jaano/widgets/placeholders/shimmer_img_placeholder.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/article_model.dart';
import '../services/firestore_service.dart';
import '../services/riverpod_providers.dart';

class ExpandedArticleScreen extends ConsumerStatefulWidget {
  final ArticlesNotifier articlesNotifier;
  final int index;
  final Article article;
  const ExpandedArticleScreen(
      {super.key,
      required this.article,
      required this.index,
      required this.articlesNotifier});

  @override
  ConsumerState<ExpandedArticleScreen> createState() =>
      _ExpandedArticleScreenState();
}

///enum to specify the section of the article being spoken
enum SpeakingSection { none, title, content, quizPrompt }

SpeakingSection currentSection = SpeakingSection.none;

class _ExpandedArticleScreenState extends ConsumerState<ExpandedArticleScreen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  bool shouldSpeak = false;
  int start = 0;
  int end = 0;

  final ScrollController _scrollController = ScrollController();
  // bool _isBottomBarVisible = false;
  double _bottomBarOffset = 1.0;

  late AnimationController _highlightController;
  late Animation<Color?> _highlightColor;
  late AnimationController _quizButtonController;
  // late Animation<double> _quizButtonScale;

  @override
  void initState() {
    print("innit state called");
    super.initState();

    _scrollController.addListener(() {
      final maxExtent = _scrollController.position.maxScrollExtent;
      final currentOffset = _scrollController.offset;

      if (maxExtent > 0) {
        // Calculate the visibility offset based on scroll position
        setState(() {
          _bottomBarOffset = 1.0 - (currentOffset / maxExtent).clamp(0.0, 1.0);
        });
      }
    });

    flutterTts.setLanguage(
        'en-US'); //todo: set language after getting from device (?)
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.2);
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });
    _loadVoices();

    ///initialise the controller for highlighting article content being spoken
    _highlightController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _highlightColor = ColorTween(
      begin: Colors.blue.withOpacity(0.3),
      end: Colors.blue.withOpacity(1.0),
    ).animate(_highlightController);

    ///initialise the controller for pulsing quiz button
    _quizButtonController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    ); // Creates a pulsing effect

    ///initialise flutterTts event handlers
    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> _loadVoices() async {
    try {
      final List<dynamic> availableVoices = await flutterTts.getVoices;
      print("Available voices: $availableVoices");
    } catch (e) {
      print("Error fetching voices: $e");
    }
  }

  void promptQuiz() {
    // var categoryManager = CategoryManager();
    if (!shouldSpeak) return;
    setState(() {
      currentSection = SpeakingSection.quizPrompt;
    });

    flutterTts.speak("Try the quiz to earn quiz points and advance in ranks!");
    _quizButtonController.forward(from: 0.0);
    if (!shouldSpeak) return;
    setState(() {
      currentSection = SpeakingSection.none;
    });

    flutterTts.setCompletionHandler(() {

      if (!shouldSpeak) return;
      setState(() {
        isSpeaking = false;
        widget.article.isCompleted = true;
        print("Article completed");
        print(widget.article.isCompleted);
        print(widget.article.title);
        // categoryManager.addCompletedArticle(widget.article.category);
        widget.articlesNotifier.completeArticle(widget.article);
        ref.read(completedArticleNo.notifier).update((state) {
          final newState = Map<String, int>.from(state); // Create a new copy of the map
          newState[widget.article.category.name] = (newState[widget.article.category.name] ?? 0) + 1; // Increment the value
          return newState; // Return the updated state
        });
      });
    });
  }

  void ttsSpeakTitle(Article article) async {
    if (!shouldSpeak) return;
    setState(() {
      currentSection = SpeakingSection.title;
    });

    flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      setState(() {
        start = startOffset;
        end = endOffset;
      });
      _highlightController.forward(from: 0.0);
    });

    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(article.title);

    if (!shouldSpeak) return;
    setState(() {
      currentSection = SpeakingSection.none;
    });

    start = 0;
    end = 0;

    await Future.delayed(const Duration(milliseconds: 500));
    await flutterTts.speak("Published by ${article.source.name} "
        "on ${DateFormat("d MMMM yyyy").format(DateTime.parse(article.publishedDate!))}");

    start = 0;
    end = 0;

    ttsSpeak(article);
  }

  void ttsSpeak(Article article) async {
    if (!shouldSpeak) return;
    setState(() {
      currentSection = SpeakingSection.content;
    });

    flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
      setState(() {
        start = startOffset;
        end = endOffset;
      });
      _highlightController.forward(from: 0.0);
    });

    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(article.content ?? "");

    if (!shouldSpeak) return;
    setState(() {
      currentSection = SpeakingSection.none;
    });

    start = 0;
    end = 0;

    /// Add points after reading completion
    await Future.delayed(const Duration(milliseconds: 500));
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(
        "Good job finishing the article! Here are 50 reading points for you.");
    final readingPointsState = ref.read(readingPointsProvider("user.id").notifier); //todo: change user id
    readingPointsState.addPoints(50);
    final FirestoreService _firestoreService = FirestoreService();
    _firestoreService.logUserAction("user.id", "article_completed", extraData: {
      "category": article.category.toString(),
      "title": article.title,
      "articleId": article.articleId,
    });
    print("log - article completed");
    print("category");
    print(article.category.toString());

    start = 0;
    end = 0;

    promptQuiz();
  }

  Future<void> ttsStop() async {
    shouldSpeak = false;
    var result = await flutterTts.stop();
    if (result == 1) setState(() => isSpeaking = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _scrollController.dispose();

    /// Stops speech when the widget is disposed
    _highlightController.dispose();
    _quizButtonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(bgColors[widget.index]),
      body: SafeArea(
        child: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage(expdBgImgs[widget.index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(overlayColors[widget.index]).withOpacity(0.5),
                Color(overlayColors[widget.index]).withOpacity(0.5)
              ]),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ///category header and back button
                CategoryHeader(index: widget.index),
                /// Title
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: currentSection == SpeakingSection.title
                          ? <TextSpan>[
                              TextSpan(
                                text: start != 0
                                    ? widget.article.title.substring(0, start)
                                    : "",
                                style: const TextStyle(
                                  color: Color(0xFF090438),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.4,
                                  height: 1.2,
                                ),
                              ),
                              TextSpan(
                                text:
                                    widget.article.title.substring(start, end),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  letterSpacing: 1.4,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                  background: Paint()
                                    ..color =
                                        _highlightColor.value ?? Colors.blue,
                                ),
                              ),
                              TextSpan(
                                text: widget.article.title.substring(end),
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF090438),
                                  height: 1.2,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ]
                          : [
                              TextSpan(
                                text: widget.article.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF090438),
                                  height: 1.2,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                ///image
                ShimmerImgPlaceholder(article: widget.article),
                const SizedBox(height: 30),

                /// Date and Source
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat("dd/MM/yyyy").format(DateTime.parse(
                          widget.article.publishedDate ??
                              DateTime.now().toString()))),
                      Text(widget.article.source.name?? ""),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                ///content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(textBoxColors[widget.index]),
                        Color(textBoxColors[widget.index])
                      ]),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                                children: currentSection ==
                                        SpeakingSection.content
                                    ? <TextSpan>[
                                        TextSpan(
                                          text:
                                              widget.article.content != null &&
                                                      start != 0
                                                  ? widget.article.content!
                                                      .substring(0, start)
                                                  : "",
                                          style: const TextStyle(
                                              color: Color(0xFF090438),
                                              fontSize: 24.0,
                                              letterSpacing: 1.4,
                                          ),

                                        ),
                                        TextSpan(
                                            text: widget.article.content != null
                                                ? widget.article.content!
                                                    .substring(start, end)
                                                : "",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24.0,
                                              fontWeight: FontWeight.bold,
                                              background: Paint()
                                                ..color =
                                                    _highlightColor.value ??
                                                        Colors.blue,
                                            )),
                                        TextSpan(
                                            text: widget.article.content != null
                                                ? widget.article.content!
                                                    .substring(end)
                                                : "",
                                            style: const TextStyle(
                                              color: Color(0xFF090438),
                                              fontSize: 24.0,
                                              letterSpacing: 1.4,

                                            )),
                                      ]
                                    : [
                                        TextSpan(
                                          text: widget.article.content != null
                                              ? widget.article.content!
                                              : "",
                                          style: const TextStyle(
                                            color: Color(0xFF090438),
                                            fontSize: 24.0,
                                            letterSpacing: 1.4,
                                          ),
                                        )
                                      ]))),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    // child: ScaleTransition(
                    //   scale: _quizButtonScale,
                    child: AnimatedBuilder(
                        animation: _quizButtonController,
                        builder: (context, child) {
                          // Animate the gradient shimmer effect
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.8),
                                  Colors.white.withOpacity(0.2),
                                ],
                                stops: [
                                  _quizButtonController.value - 0.3,
                                  _quizButtonController.value,
                                  _quizButtonController.value + 0.3,
                                ],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcATop,
                            // child: Container(
                            //   decoration: BoxDecoration(
                            //     shape: BoxShape.rectangle,
                            //     boxShadow: [
                            //       BoxShadow(
                            //         spreadRadius: 1.0, // Spread radius
                            //         color: Colors.black
                            //             .withOpacity(0.2), // Shadow color
                            //         blurRadius: 5.0, // Softness of shadow
                            //       ),
                            //     ],
                            //     borderRadius: BorderRadius.circular(10.0),
                            //   ),
                              child: IconButton(
                                icon: Image.asset(
                                  quizIcons[widget.index],
                                ),
                                onPressed: () {
                                  _quizButtonController
                                      .stop(); // Stop animation when button is pressed
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizScreen(
                                        article: widget.article,
                                        index: widget.index,
                                      ),
                                    ),
                                  );
                                },
                              // ),
                            ),
                          );
                        }),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.10),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: Offset(0, _bottomBarOffset),
              duration: const Duration(milliseconds: 200), // Smooth sliding
              curve: Curves.easeInOut,
              child: Align(
                alignment: Alignment.bottomCenter,
                child:
                    SafeArea(child: BottomNavbar(carouselIndex: widget.index)),
              ),
            ),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isSpeaking) {
            ttsStop();
          } else {
            setState(() {
              shouldSpeak = true; // Enable speaking
            });
            ttsSpeakTitle(widget.article);
          }
        },
        backgroundColor: const Color(0xFF090438),
        child: Icon(
          isSpeaking ? Icons.pause_circle : Icons.play_circle,
          color: Colors.white,
          size: 40.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      // bottomNavigationBar: const BottomNavbar(),
    );
  }
}

//todo:
//if you swipe right/left, category is changed
//control font size irrespective of device settings.

//while storing to database, add fav icon too. - if favicon present in cache alr, dont do.

//how to get same across devices?
