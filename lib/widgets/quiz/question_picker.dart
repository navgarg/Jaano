import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants.dart';
import '../../services/riverpod_providers.dart';

class QuestionPicker extends ConsumerStatefulWidget {
  final int index;
  const QuestionPicker({super.key, required this.index});

  @override
  ConsumerState<QuestionPicker> createState() => _QuestionPickerState();
}

class _QuestionPickerState extends ConsumerState<QuestionPicker> {

  @override
  Widget build(BuildContext context) {
    final currQues = ref.watch(questionIndexProvider);

    return Column(
      children: [
        const SizedBox(
        height: 5.0,
      ),
        SizedBox(
          height: MediaQuery
              .of(context)
              .size
              .height * 0.05,
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
                    "QUESTION $currQues",
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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
          height: 10.0,
        ),
      ],
    );
  }
}
