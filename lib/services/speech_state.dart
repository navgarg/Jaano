import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/article_model.dart';
import 'riverpod_providers.dart';

class SpeechState {
  final bool speechEnabled;
  late String wordsSpoken;
  final bool isListening;
  final bool isProcessing;

  SpeechState({
    this.speechEnabled = false,
    this.wordsSpoken = "",
    this.isListening = false,
    this.isProcessing = false,
  });

  SpeechState copyWith({
    bool? speechEnabled,
    String? wordsSpoken,
    bool? isListening,
    bool? isProcessing,
  }) {
    return SpeechState(
      speechEnabled: speechEnabled ?? this.speechEnabled,
      wordsSpoken: wordsSpoken ?? this.wordsSpoken,
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing
    );
  }
}

class SpeechStateNotifier extends StateNotifier<SpeechState> {
  final Ref ref;

  SpeechStateNotifier(this.ref) : super(SpeechState());

  // Future<void> startProcessing() async {
  //   state = state.copyWith(isProcessing: true);
  // }
  //
  // Future<void> finishProcessing() async {
  //   state = state.copyWith(isProcessing: false);
  // }

  Future<void> initSpeech() async {
    print("speech initialised");
    final speechToText = ref.read(speechToTextProvider);
    final isAvailable = await speechToText.initialize();
    state = state.copyWith(speechEnabled: isAvailable);
    state.wordsSpoken = "";
  }

  Future<void> startListening() async {
    final speechToText = ref.read(speechToTextProvider);
    await speechToText.listen(
      onResult: (result) {
        state = state.copyWith(wordsSpoken: result.recognizedWords);
      },
    );
    state = state.copyWith(isListening: true);
  }

  Future<void> stopListening(Article article, int index) async {
    final speechToText = ref.read(speechToTextProvider);
    await speechToText.stop();
    state = state.copyWith(isListening: false);
    state = state.copyWith(isProcessing: true);
    final answerNotifier = ref.read(answerProvider.notifier);
    if(state.wordsSpoken.isNotEmpty) {
      answerNotifier.checkAnswer(article, state.wordsSpoken, index);
    }
    else{
      Fluttertoast.showToast(msg: "Please provide an answer. ", toastLength: Toast.LENGTH_LONG);
      state = state.copyWith(isProcessing: false);
    }
    // if (state.wordsSpoken == article.questions![index].answer) {
    //   Fluttertoast.showToast(
    //     msg: "correct!",
    //     toastLength: Toast.LENGTH_SHORT,
    //   );
    //       print("correct");
    //     }
    //     else{
    //
    //   Fluttertoast.showToast(
    //     msg: "wrong",
    //     toastLength: Toast.LENGTH_SHORT,
    //   );
    //       print("wrong");
    //     }
  }
}