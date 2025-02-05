import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaano/services/riverpod_providers.dart';
import 'package:jaano/widgets/category_header.dart';

import '../constants.dart';
import '../widgets/navbar/bottom_navbar.dart';
import '../widgets/quiz/question_picker.dart';

class CheckAnsScreen extends ConsumerStatefulWidget {
  final int index;
  final AnswerData answerData;
  const CheckAnsScreen(
      {super.key, required this.index, required this.answerData});

  @override
  ConsumerState<CheckAnsScreen> createState() => _CheckAnsScreen();
}

class _CheckAnsScreen extends ConsumerState<CheckAnsScreen> {
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
          SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ///category header
                  CategoryHeader(index: widget.index),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Color(bgColors[widget.index]).withOpacity(0.76), Color(bgColors[widget.index]).withOpacity(0.76)])
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

                  SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Color(bgColors[widget.index]), Color(bgColors[widget.index])]),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
                    ]),
                  ),
                ]),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: const Offset(0, 0), //todo: update
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
