import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:jaano/constants.dart';

import '../../models/article_model.dart';
import '../../services/riverpod_providers.dart';

void showProcessingDialog(BuildContext context, WidgetRef ref, int index) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(bgColors[index]),
        title: const Text("Processing..."),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Analyzing your response..."),
          ],
        ),
      );
    },
  );
}

void showAnswerDialog(BuildContext context, String answer, int index) {

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Color(bgColors[index]),
        title: const Text("Feedback"),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Text(
                answer,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}