import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/screens/expanded_article_screen.dart';
import 'package:jaano/services/claude_api_service.dart';
import 'package:jaano/widgets/navbar/bottom_navbar.dart';
import 'package:jaano/widgets/carousel.dart';
import 'package:jaano/widgets/date_picker.dart';
import 'package:jaano/widgets/list_tile.dart';

import '../constants.dart';
import '../models/article_model.dart';
import '../services/riverpod_providers.dart';
import '../widgets/placeholders/shimmer_list_placeholder.dart';

//images

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final carouselIndex = ref.watch(carouselIndexProvider);
    // print("summary");

    // getClaudeQuestions("Apple is working on a new iPhone called the iPhone SE 4! It's going to be smaller than the regular iPhones, making it easier for little hands to hold. The exciting part is that it will have the same powerful chip as the more expensive iPhones, so you can play games and use apps just as smoothly. It might also have a better camera for taking sharper photos and videos. The body of the iPhone SE 4 could be made of tougher materials to prevent scratches and cracks if you accidentally drop it. Apple is aiming to launch this new iPhone by early next year, so you may get to see it soon!");
    // final articles = ref.watch(articlesProvider);
    final articlesNotifier = ref.read(articlesProvider.notifier);
    final articlesState = ref.watch(articlesProvider);
    final expandedPanels = ref.watch(expandedPanelsProvider);
    // final articleCompleted = ref.watch(articleCompletionProvider);

    /// Ensure articles are fetched when the widget is built
    // occurs only once - after the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('addPostFrameCallback: articlesState = $articlesState');

      // Avoid re-fetching if the articles are already loaded
      if (articlesState is AsyncData) return;

      // Fetch articles if not already loaded
      print('Before fetch: $articlesState');
      articlesNotifier.fetchArticles(categories[carouselIndex]);
      print('After fetch: $articlesState');
    });

    ///re-fetch articles everytime category is changed
    ref.listen<int>(carouselIndexProvider, (previousIndex, newIndex) {
      articlesNotifier.fetchArticles(categories[newIndex]);
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            //stack used since widgets are overlapping
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(homeBgImgs[carouselIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 5.0,
                ),
                const DatePicker(),
                const SizedBox(height: 10.0),
                const Carousel(),
                Expanded(
                  child: articlesState.when(
                    loading: () {
                      // print(
                      //     '🔄 AsyncLoading state detected! Showing shimmer...');
                      return const ShimmerPlaceholder();
                    }, // Use shimmer during loading
                    data: (articles) {
                      if (articles.isEmpty) {
                        return const Center(
                            child: Text('No articles available.'));
                      }

                      // if (articles.isEmpty && ref.read(articlesProvider) is AsyncLoading) {
                      //   return const ShimmerPlaceholder(); // Show shimmer instead of "No articles available"
                      // }
                      //
                      // if (articles.isEmpty) {
                      //   return const Center(
                      //     child: Text('No articles available.'),
                      //   );
                      // }
                      // Initialize expanded panels
                      // WidgetsBinding.instance.addPostFrameCallback((_) {
                      //   if (expandedPanels.isEmpty || expandedPanels.length != articles.length) {
                      //     ref.read(expandedPanelsProvider.notifier)
                      //         .initialize(articles.length);
                      //   }
                      // });
                      if (expandedPanels.isEmpty ||
                          expandedPanels.length != articles.length) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref
                              .read(expandedPanelsProvider.notifier)
                              .initialize(articles.length);
                        });
                      }

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
                                CustomListTile(
                                    article: article,
                                    carouselIndex: carouselIndex,
                                    articlesNotifier: articlesNotifier),
                                // Add spacing below each panel
                                const SizedBox(height: 16.0),
                              ],
                            );
                          },
                        ),
                      );
                    },
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ),
            BottomNavbar(
              carouselIndex: carouselIndex,
            ),
          ],
        ),
      ),
    );
  }
}
//todo: make separate single text style to be used across app for uniformity.

//greyed and locked icons for other categories.
//other categories unlocked only by completing the prev category.
//when tech completed, economy is highlighted.
//rings are empty when new category is started

//scroll automatically to follow highlighted text

//natural audio from tts. store in firebase.

//online tts - how? send request everyday and store in firebase? whisper.
//diff icon for mic button

//make shadow inner instead of outer
