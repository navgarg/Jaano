import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/firestore_service.dart';
import '../models/article_model.dart';
import '../constants.dart';
import '../widgets/speech_state.dart';

// final articlesProvider = FutureProvider<List<Article>>((ref) async {
//   final selectedCategory = ref.watch(selectedCategoryProvider);
//   FirestoreService client = FirestoreService();
//   print(selectedCategory);
//   return await client.getFirebaseArticles(selectedCategory);
// });
final articlesProvider =
StateNotifierProvider<ArticlesNotifier, AsyncValue<List<Article>>>((ref) => ArticlesNotifier());

class ArticlesNotifier extends StateNotifier<AsyncValue<List<Article>>> {
  ArticlesNotifier() : super(const AsyncValue.loading());

  // Fetch articles (example placeholder for actual fetch logic)
  Future<void> fetchArticles(Categories selectedCategory) async {
    FirestoreService client = FirestoreService();
    try {
      state = const AsyncValue.loading();
      final articles = await client.getFirebaseArticles(selectedCategory);
      state = AsyncValue.data(articles); // Update the state with fetched articles
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update the completion status of an article
  void completeArticle(Article art) {
    state.whenData((articles) {
      final updatedArticles = articles.map((article) {
        if (article == art) {
          return Article(
            source: article.source,
            author: article.author,
            questions: article.questions,
            title: article.title,
            category: article.category,
            description: article.description,
            url: article.url,
            urlToImage: article.urlToImage,
            publishedAt: article.publishedAt,
            content: article.content,
            isCompleted: true, // Change only this field
          );
        }
        return article;
      }).toList();

      // Update state with modified articles list
      state = AsyncValue.data(updatedArticles);
    });
  }
}

class ExpandedPanelsNotifier extends StateNotifier<List<bool>> {
  ExpandedPanelsNotifier() : super([]);

  void initialize(int length) {
    if (length > 0) {
      state = List.filled(length, false);
      print('ExpandedPanels initialized with $length entries.');
    } else {
      state = []; // Do nothing for an empty list
    }
  }

  void togglePanel(int index) {
    if (index >= 0 && index < state.length) {
      state = List.generate(
        state.length,
            (i) => i == index ? !state[i] : state[i],
      );
    }
    // state = List.generate(state.length, (i) => i == index ? !state[i] : false);
  }
}

final expandedPanelsProvider =
StateNotifierProvider<ExpandedPanelsNotifier, List<bool>>(
      (ref) => ExpandedPanelsNotifier(),
);


final carouselIndexProvider = StateProvider<int>((ref) => 0);

final selectedCategoryProvider = Provider<Categories>((ref) {
  print("page changed");
  final currentIndex = ref.watch(carouselIndexProvider);
  List<Categories> categoryEnums = ["economy", "nature", "food", "science", "sports", "technology"]
      .map((str) => Categories.values.byName(str))
      .toList();

  return categoryEnums[currentIndex]; // Map index to the enum or category list
});
// final expandedPanelsProvider = StateProvider<List<bool>>((ref) => []);

final questionIndexProvider = StateProvider<int>((ref) => 1);

final speechToTextProvider = Provider<SpeechToText>((ref) => SpeechToText());

final speechStateProvider = StateNotifierProvider<SpeechStateNotifier, SpeechState>(
      (ref) => SpeechStateNotifier(ref),
);
