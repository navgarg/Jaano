import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/screens/expanded_article_screen.dart';
import 'package:jaano/widgets/bottom_navbar.dart';

import '../constants.dart';
import '../models/article_model.dart';
import '../services/riverpod_providers.dart';
import '../widgets/shimmer_list_placeholder.dart';

//images

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var categoryManager = CategoryManager();

    /// Watch providers
    final carouselIndex = ref.watch(carouselIndexProvider);
    // final articles = ref.watch(articlesProvider);
    final articlesNotifier = ref.read(articlesProvider.notifier);
    final articlesState = ref.watch(articlesProvider);
    final expandedPanels = ref.watch(expandedPanelsProvider);
    // final articleCompleted = ref.watch(articleCompletionProvider);

    /// Ensure articles are fetched when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('addPostFrameCallback: articlesState = $articlesState');

      /// Avoid re-fetching if the articles are already loaded
      // if (articlesState.isLoading || articlesState is AsyncData) return;
      if (articlesState is AsyncData) return;

      /// Fetch articles if not already loaded
      print('Before fetch: $articlesState');
      articlesNotifier.fetchArticles(categories[carouselIndex]);
      print('After fetch: $articlesState');
    });

    ref.listen<int>(carouselIndexProvider, (previousIndex, newIndex) {
      articlesNotifier.fetchArticles(categories[newIndex]);
    });

    String _getCategoryIcon(int index, WidgetRef ref) {
      final categoryManager = CategoryManager();
      final completionStatus = categoryManager.completionStatus(
          categories[index]);
      if (completionStatus == 0) return catIcons0[index];
      if (completionStatus == 1) return catIcons1[index];
      if (completionStatus == 2) return catIcons2[index];
      return catIcons3[index];
    }

    final scrollController = ScrollController(
      initialScrollOffset:
      carouselIndex * MediaQuery
          .of(context)
          .size
          .width * 0.28,
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(bgImgs[carouselIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(children: [
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
                        onPressed: () {},
                        icon: const ImageIcon(
                            AssetImage("assets/prev_date.png"))),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat("dd/MM/yyyy").format(DateTime.now()),
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                        onPressed: () {},
                        icon: const ImageIcon(
                            AssetImage("assets/next_date.png"))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.13,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final label = labels[index];
                  // final String image;
                  // if (categoryManager.completionStatus(categories[index]) ==
                  //     0) {
                  //   image = catIcons0[index];
                  // } else if (categoryManager
                  //         .completionStatus(categories[index]) ==
                  //     1) {
                  //   image = catIcons1[index];
                  // } else if (categoryManager
                  //         .completionStatus(categories[index]) ==
                  //     2) {
                  //   image = catIcons2[index];
                  // } else {
                  //   image = catIcons3[index];
                  // }
                  final image = _getCategoryIcon(index, ref);

                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(carouselIndexProvider.notifier)
                          .state = index;
                      // articlesNotifier.fetchArticles(categories[carouselIndex]);

                      // Scroll to the selected item
                      final offset =
                          index * MediaQuery
                              .of(context)
                              .size
                              .width * 0.24;
                      scrollController.animateTo(
                        offset,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.24,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),

                      ///controls the spacing between successive elements in carousel
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (carouselIndex ==
                                  index) // Add shadow only for selected item
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.25), // Shadow color
                                        blurRadius: 4.0, // Softness of shadow
                                      ),
                                    ],
                                  ),
                                ),
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey.shade200,
                                child: ClipOval(
                                  child: Image.asset(
                                    image,
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: carouselIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: articlesState.when(
                data: (articles) {
                  if (articles.isEmpty) {
                    return const Center(
                      child: Text('No articles available.'),
                    );
                  }

                  /// Initialize expanded panels
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (expandedPanels.isEmpty ||
                        expandedPanels.length != articles.length) {
                      ref
                          .read(expandedPanelsProvider.notifier)
                          .initialize(articles.length);
                    }
                  });
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        // final isExpanded = expandedPanels[index];

                        return Column(
                          children: [
                            Container(
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.18,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Color(bgColors[carouselIndex]),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                leading: Image.asset('assets/circuit.png'),
                                title: Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: article.isCompleted
                                    ? const Icon(Icons.check_circle_outline)
                                    : const Icon(Icons.navigate_next_rounded),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ExpandedArticleScreen(
                                                article: article,
                                                articlesNotifier: articlesNotifier,
                                                index: carouselIndex,
                                              )));
                                },
                              ),
                            ),
                            // Add spacing below each panel
                            const SizedBox(height: 16.0),
                          ],
                        );
                      },
                    ),
                  );
                },
                loading: () =>
                const ShimmerPlaceholder(), // Use shimmer during loading
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
          ),
          const BottomNavbar(),
        ],
        ),
      ),
    );

  }
}
//on start listening, make overlay and mic animation.

//cache the imgs and stuff in shared preferences.

//greyed and locked icons for other categories.
//other categories unlocked only by completing the prev category.
//when tech completed, economy is highlighted.
//rings are empty when new category is started
//shadow to highlight the category selected

//animation for smooth transition from non expanded view to expanded view.

//article read when tts completed.

//article points being added - animation? show something
//bottom bar use elements not image.

