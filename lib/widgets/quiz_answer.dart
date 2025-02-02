import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:jaano/constants.dart';

import '../models/article_model.dart';
import '../services/riverpod_providers.dart';

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
//         content: Consumer(
//           builder: (context, ref, child) {
//             final answerState = ref.watch(answerProvider);
//
//             if (answerState.isLoading) {
//               print("if ans.isloading: ${answerState.isLoading}, Value: ${answerState.hasValue}, Error: ${answerState.hasError}");
//               return const Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 10),
//                   Text("Analyzing your response..."),
//                 ],
//               );
//             } else if (answerState.hasValue) {
//               print("if ans.hasvalue: ${answerState.isLoading}, Value: ${answerState.hasValue}, Error: ${answerState.hasError}");
//               // Close the current dialog and show the final answer
//               // WidgetsBinding.instance.addPostFrameCallback((_) {
//               //   if (Navigator.of(context).canPop()) {
//               //     Navigator.of(context).pop(); // Close processing dialog
//               //   }
//                 // Delay showing the answer dialog to avoid quick state change clash
//                 Future.delayed(Duration.zero, () {
//                   Navigator.of(context).pop();
//                   showAnswerDialog(context, answerState.value!, index);
//
//                 });
//               print("after: ${answerState.isLoading}, Value: ${answerState.hasValue}, Error: ${answerState.hasError}");
//               // });
//             } else if (answerState.hasError) {
//               return Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text("Error occurred while processing."),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.of(context, rootNavigator: true).pop();
//                     },
//                     child: const Text("OK"),
//                   )
//                 ],
//               );
//             }
//
//             return Container(); // Default case
//           },
//         ),
//       );
//     },
//   );
// }

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