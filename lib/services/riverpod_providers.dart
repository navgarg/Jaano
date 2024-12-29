import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/article_model.dart';
import '../constants.dart';

final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  FirestoreService client = FirestoreService();
  print(selectedCategory);
  return await client.getFirebaseArticles(selectedCategory); //todo: update
});

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
