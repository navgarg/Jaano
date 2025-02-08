import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaano/services/riverpod_providers.dart';
import 'package:jaano/widgets/category_header.dart';

import '../constants.dart';
import '../models/article_model.dart';
import '../services/firestore_service.dart';
import '../widgets/navbar/bottom_navbar.dart';
import '../widgets/quiz/question_picker.dart';

class CheckAnsScreen extends ConsumerStatefulWidget {
  final Article article;
  final int quesIndex;
  final int index;
  final AnswerData answerData;
  const CheckAnsScreen(
      {super.key, required this.index, required this.answerData, required this.article, required this.quesIndex});

  @override
  ConsumerState<CheckAnsScreen> createState() => _CheckAnsScreen();
}
//todo: check if user has already answered this question

class _CheckAnsScreen extends ConsumerState<CheckAnsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback( (_) {
      final quizPointsState = ref.read(
          quizPointsProvider("user.id").notifier); //todo: update userid
      int qps;
      if (widget.answerData.rating > 5) {
        print("added qps");
        quizPointsState.addPoints(50);
        qps = 50;
      }
      else {
        qps = 0;
      }
      final FirestoreService _firestoreService = FirestoreService();
      _firestoreService.logUserAction("user.id", "quiz_attempted", extraData: {
        "category": widget.article.category.toString(),
        "title": widget.article.title,
        "question": widget.article.questions![widget.quesIndex].question,
        "feedback": widget.answerData.feedback,
        "rating": widget.answerData.rating,
        "qps earned": qps,
        "articleId": widget.article.id,
      });
      print("log quiz attempted");
      print("qps earned");
      print(qps);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(expdBgImgs[widget.index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ///category header
                  CategoryHeader(index: widget.index),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 13.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(bgColors[widget.index]).withOpacity(0.5), Color(bgColors[widget.index]).withOpacity(0.5)]),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                    Image.asset(
                      widget.answerData.rating > 5
                          ? "assets/correct_ans.png"
                          : "assets/wrong_ans.png",
                      height: MediaQuery.of(context).size.height * 0.20,
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        widget.answerData.rating > 5
                            ? "Congratulations! Your answer is correct."
                            : "Your answer is incorrect.",
                        style: const TextStyle(
                          color: Color(0xFF090438),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Text(
                    //     "correctness level: ${widget.answerData.rating} / 10",
                    //     style: const TextStyle(
                    //       color: Color(0xFF090438),
                    //       fontSize: 20.0,
                    //     ),
                    //     textAlign: TextAlign.justify,
                    //   ),
                    // ),
                    // const SizedBox(height: 20),

                    Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 20.0),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.33,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Color(bgColors[widget.index]), Color(bgColors[widget.index])]),
                              border: Border.all(color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5), // Shadow color
                                  spreadRadius: 3, // How much the shadow spreads
                                  blurRadius: 5, // Softness of the shadow
                                  offset: const Offset(-5, 5), // Moves shadow left (-X) and down (+Y)
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                              child: SingleChildScrollView(
                                child: Text(
                                widget.answerData.feedback,
                                style: const TextStyle(
                                  color: Color(0xFF090438),
                                  fontSize: 16.0,
                                ),
                                textAlign: TextAlign.justify,
                                                        ),
                              ),
                            ),
                        ),
                      ),
                      ]),
                    ),
                  ),
                ]),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: const Offset(0, 0),
              duration: const Duration(milliseconds: 200), // Smooth sliding
              curve: Curves.easeInOut,
              child: Align(
                alignment: Alignment.bottomCenter,
                child:
                    SafeArea(child: BottomNavbar(carouselIndex: widget.index)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
