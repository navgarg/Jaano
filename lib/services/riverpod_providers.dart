import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jaano/services/article_api_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/firestore_service.dart';
import '../models/article_model.dart';
import '../constants.dart';
import 'claude_api_service.dart';
import 'speech_state.dart';

final completedArticleNo = StateProvider<Map<String, int>>((ref) => {});


final articlesProvider =
NotifierProvider<ArticlesNotifier, AsyncValue<List<Article>>>(ArticlesNotifier.new);

class ArticlesNotifier extends Notifier<AsyncValue<List<Article>>> {
  @override
  AsyncValue<List<Article>> build() => const AsyncValue.loading();
  // ArticlesNotifier() : super(const AsyncValue.loading());

  // Fetch articles (example placeholder for actual fetch logic)
  Future<void> fetchArticles(Categories selectedCategory) async {
    // if (state.isRefreshing) return;
    FirestoreService client = FirestoreService();
    state = const AsyncLoading();
    try {
      final articles = await client.getFirebaseArticles(selectedCategory);
      // final articles = await ApiService().getArticle(selectedCategory);
      if(articles.isEmpty){
        print("request alr in prog");
        state = const AsyncLoading();
        return;
      }
      final completedArticles = await client.getCompletedArticles("user.id"); //todo: update user id
      final completedArticleIds = completedArticles["comp_arts"];
      final comp_cats = completedArticles["comp_cats"];
      Map<String, int> completedNo = {};
      for (var cat in comp_cats){
        completedNo[cat.toString()] = (completedNo[cat.toString()] ?? 0) + 1;
      }
      ref.read(completedArticleNo.notifier).state = completedNo;
      print(ref.read(completedArticleNo.notifier).state);
      print("Current state of completed articles: ${ref.watch(completedArticleNo)}");
      print("got completed articles");
      print(completedArticleIds);
      final updatedArticles = articles.map((article) {
        return article.copyWith(
          isCompleted: completedArticleIds.contains(article.articleId),
        );
      }).toList();
      print(updatedArticles);
      state = AsyncValue.data(updatedArticles); // Update the state with fetched articles
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
            questions: article.questions,
            title: article.title,
            category: article.category,
            description: article.description,
            articleId: article.articleId,
            articleLink: article.articleId,
            imageLink: article.imageLink,
            publishedDate: article.publishedDate,
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

class ExpandedPanelsNotifier extends Notifier<List<bool>> {
  @override
  List<bool> build() => [];
  // ExpandedPanelsNotifier() : super([]);

  void initialize(int length) {
    if (length > 0) {
      state = List.filled(length, false);
      print('ExpandedPanels initialized with $length entries.');
    } else {
      state = []; // Do nothing for an empty list
    }
  }

  /// Toggle the state of expansion panel at the given index
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
NotifierProvider<ExpandedPanelsNotifier, List<bool>>(ExpandedPanelsNotifier.new);


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

final speechStateProvider = NotifierProvider<SpeechStateNotifier, SpeechState>(SpeechStateNotifier.new);

class PointsState {
  final int totalPoints;
  final int addedPoints;
  final bool isAnimating;

  PointsState({
    required this.totalPoints,
    this.addedPoints = 0,
    this.isAnimating = false,
  });

  PointsState copyWith({
    int? totalPoints,
    int? addedPoints,
    bool? isAnimating,
  }) {
    return PointsState(
      totalPoints: totalPoints ?? this.totalPoints,
      addedPoints: addedPoints ?? this.addedPoints,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}

class PointsNotifier extends StateNotifier<PointsState> {
  final FirestoreService _firestoreService = FirestoreService();
  late final PointType pointType;
  late final String userId;

  // PointsNotifier(String userId, PointType articlePoints);

  // static PointsNotifier create(String userId, PointType pointType) {
  //   final notifier = PointsNotifier();
  //   notifier.userId = userId;
  //   notifier.pointType = pointType;
  //   return notifier;
  // }
  //
  // @override
  // PointsState build() {
  //   _initialize();
  //   return PointsState(totalPoints: 0);
  // }
  PointsNotifier(this.userId, this.pointType) : super(PointsState(totalPoints: 0)) {
    _initialize();
  }

  // Load initial points from Firestore (cached first)
  Future<void> _initialize() async {
    final cachedPoints = await _firestoreService.getUserPoints(userId, pointType);
    state = state.copyWith(totalPoints: cachedPoints);

    // Listen to Firestore updates in real-time
    _firestoreService.streamUserPoints(userId, pointType).listen((newPoints) { //todo: dispose firestore listener
      if (!state.isAnimating && newPoints != state.totalPoints) { // Avoid resetting points during animation
        state = state.copyWith(totalPoints: newPoints);
      }
    });
  }

  // Add points with animation and update Firestore
  Future<void> addPoints(int points) async {
    final updatedPoints = state.totalPoints + points;
    state = state.copyWith(addedPoints: points, isAnimating: true);
    // Simulate a delay for animation
    await Future.delayed(const Duration(seconds: 3));
    state = state.copyWith(totalPoints: updatedPoints, addedPoints: 0, isAnimating: false);
    // Sync new points to Firestore
    await _firestoreService.updateUserPoints(userId, updatedPoints, pointType);
    print("added pts to firebase");
    print(pointType.toString());
  }
}

// final readingPointsProvider = NotifierProvider.family<PointsNotifier, PointsState, String>(
//       (ref, userId) => PointsNotifier(userId, PointType.articlePoints),
// );
final readingPointsProvider = StateNotifierProvider.family<PointsNotifier, PointsState, String>(
      (ref, userId) => PointsNotifier(userId, PointType.articlePoints),
);

final firebaseServiceProvider = Provider((ref) => FirestoreService());

final quizPointsProvider = StateNotifierProvider.family<PointsNotifier, PointsState, String>(
      (ref, userId) => PointsNotifier(userId, PointType.quizPoints),
  // PointsNotifier.new,
);



class AnswerData {
  final String feedback;
  final int rating;

  AnswerData({required this.feedback, required this.rating});
}

final answerProvider = AsyncNotifierProvider<AnswerNotifier, AnswerData?>(() => AnswerNotifier());

class AnswerNotifier extends AsyncNotifier<AnswerData?> {
  @override
  Future<AnswerData?> build() async => null; // Initial state is null

  Future<void> checkAnswer(Article article, String userAnswer, int quesIndex) async {
    state = const AsyncValue.loading(); // Show loading indicator
    try {
      List<dynamic> response = await checkClaudeAnswer(
          article, userAnswer, quesIndex);
      state = AsyncValue.data(
          AnswerData(feedback: response[0], rating: response[1]));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}