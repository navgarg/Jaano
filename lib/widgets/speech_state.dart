import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/article_model.dart';
import '../services/riverpod_providers.dart';

class SpeechState {
  final bool speechEnabled;
  final String wordsSpoken;
  final bool isListening;

  SpeechState({
    this.speechEnabled = false,
    this.wordsSpoken = "",
    this.isListening = false,
  });

  SpeechState copyWith({
    bool? speechEnabled,
    String? wordsSpoken,
    bool? isListening,
  }) {
    return SpeechState(
      speechEnabled: speechEnabled ?? this.speechEnabled,
      wordsSpoken: wordsSpoken ?? this.wordsSpoken,
      isListening: isListening ?? this.isListening,
    );
  }
}

class SpeechStateNotifier extends StateNotifier<SpeechState> {
  final Ref ref;

  SpeechStateNotifier(this.ref) : super(SpeechState());

  Future<void> initSpeech() async {
    print("speech initialised");
    final speechToText = ref.read(speechToTextProvider);
    final isAvailable = await speechToText.initialize();
    state = state.copyWith(speechEnabled: isAvailable);
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

  Future<void> stopListening(Article article) async {
    final speechToText = ref.read(speechToTextProvider);
    await speechToText.stop();
    state = state.copyWith(isListening: false);
    if (state.wordsSpoken == article.questions![0].answer) {
          print("correct");
        }
        else{

          print("wrong");
        }
  }
}