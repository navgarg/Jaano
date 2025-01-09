import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/constants.dart';
import 'package:jaano/screens/home_screen.dart';
import 'package:jaano/screens/quiz_screen.dart';
import 'package:jaano/widgets/bottom_navbar.dart';
import 'package:jaano/widgets/shimmer_img_placeholder.dart';
import 'package:shimmer/shimmer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/article_model.dart';

class ExpandedArticleScreen extends StatefulWidget {
  final int index;
  final Article article;
  const ExpandedArticleScreen({
    super.key,
    required this.article,
    required this.index,
  });

  @override
  State<ExpandedArticleScreen> createState() => _ExpandedArticleScreenState();
}

enum SpeakingSection { none, title, content, quizPrompt }

SpeakingSection currentSection = SpeakingSection.none;

class _ExpandedArticleScreenState extends State<ExpandedArticleScreen>
    with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  bool shouldSpeak = false;
  int start = 0;
  int end = 0;

  late AnimationController _highlightController;
  late Animation<Color?> _highlightColor;
  late AnimationController _quizButtonController;
  late Animation<double> _quizButtonScale;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage(
        'en-US'); //todo: set language after getting from device (?)
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.2);
    flutterTts.setStartHandler(() {
      setState(() {
        isSpeaking = true;
      });
    });

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

    _quizButtonScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _quizButtonController,
        curve: Curves.easeInOut,
      ),
    );

    ///initialise flutterTts event handlers
    flutterTts.setCompletionHandler(() {
      if (!shouldSpeak) return;
      setState(() {
        isSpeaking = false;
        widget.article.isCompleted = true;
        //todo: add animation for reading points.
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  void promptQuiz() {
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
    //"Published by ${article.source.name} "
    //         "on ${DateFormat("d MMMM yyyy").format(DateTime.parse(article.publishedAt!))}"
    if (!shouldSpeak) return;
    setState(() {
      currentSection = SpeakingSection.none;
    });

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
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/tech/tech_expanded_bg.png"), //todo: update bg img
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ///category header and back button
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
                              Navigator.pop(context);
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            )),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            labels[widget.index],
                            style: const TextStyle(
                              fontSize: 16.0,
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
                            onPressed: () {},
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.transparent,
                            )),
                      ),
                    ],
                  ),
                ),

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
                                  fontSize: 27,
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
                                  fontSize: 27,
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
                                  fontSize: 27,
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
                                  fontSize: 27,
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
                          widget.article.publishedAt ??
                              DateTime.now().toString()))),
                      Text(widget.article.source.name),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                ///content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF9585D2), Color(0xFF9585D2)]),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        child: RichText(
                            textAlign: TextAlign.left,
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
                                              letterSpacing: 1.4),
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
                            child: IconButton(
                              icon: Image.asset("assets/tech/quiz.png"),
                              onPressed: () {
                                _quizButtonController
                                    .stop(); // Stop animation when button is pressed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        QuizScreen(article: widget.article),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
          const BottomNavbar(),
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
      // bottomNavigationBar: const BottomNavbar(),
    );
  }
}

//todo:
//change imgs for background to show different categories
//if you swipe right/left, category is changed
//control font size irrespective of device settings.

//use Ai to rephrase title to 12 words

//after scroll then only bottom nav is visible.

//highlight the title as well for tts.
//pause after title.
//fix the highlighting

//while storing to database, add fav icon too. - if favicon present in cache alr, dont do.

//male/female voices for tts? check different options.
//how to get same across devices?

//have to click stop listening 3 times to stop. why?

//settle paddings on listTiles. make custom container instead of list tile.
