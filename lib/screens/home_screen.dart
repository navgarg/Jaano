import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/screens/expanded_article_screen.dart';
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
    // final articles = ref.watch(articlesProvider);
    final articlesNotifier = ref.read(articlesProvider.notifier);
    final articlesState = ref.watch(articlesProvider);
    final expandedPanels = ref.watch(expandedPanelsProvider);
    // final articleCompleted = ref.watch(articleCompletionProvider);

    /// Ensure articles are fetched when the widget is built
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
        child: Stack(children: <Widget>[ //stack used since widgets are overlapping
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(homeBgImgs[carouselIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(children: [
            const SizedBox(
              height: 5.0,
            ),

            const DatePicker(),

            const SizedBox(height: 10.0),

            const Carousel(),

            Expanded(
              child: articlesState.when(
                data: (articles) {
                  if (articles.isEmpty) {
                    return const Center(
                      child: Text('No articles available.'),
                    );
                  }
                  // Initialize expanded panels
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
                            // Container(
                            //   height:
                            //   MediaQuery
                            //       .of(context)
                            //       .size
                            //       .height * 0.18,
                            //   alignment: Alignment.center,
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(10.0),
                            //     color: Color(bgColors[carouselIndex]),
                            //   ),
                            //   padding: const EdgeInsets.symmetric(
                            //       vertical: 8.0, horizontal: 16.0),
                            //   child: ListTile(
                            //     leading: Image.asset('assets/circuit.png'),
                            //     title: Text(
                            //       article.title,
                            //       style: const TextStyle(
                            //         fontSize: 16.0,
                            //         color: Colors.black,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //       maxLines: 4,
                            //       overflow: TextOverflow.ellipsis,
                            //     ),
                            //     trailing: article.isCompleted
                            //         ? const Icon(Icons.check_circle_outline)
                            //         : const Icon(Icons.navigate_next_rounded),
                            //     onTap: () {
                            //       Navigator.push(
                            //           context,
                            //           MaterialPageRoute(
                            //               builder: (context) =>
                            //                   ExpandedArticleScreen(
                            //                     article: article,
                            //                     articlesNotifier: articlesNotifier,
                            //                     index: carouselIndex,
                            //                   )));
                            //     },
                            //   ),
                            // ),
                            CustomListTile(article: article, carouselIndex: carouselIndex, articlesNotifier: articlesNotifier),
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
          BottomNavbar(carouselIndex: carouselIndex,),
        ],
        ),
      ),
    );

  }
}
//todo: what if multiple queries at the same time? filter unique elements? or fix time to send query independently

//todo: make separate single text style to be used across app for uniformity.


//greyed and locked icons for other categories.
//other categories unlocked only by completing the prev category.
//when tech completed, economy is highlighted.
//rings are empty when new category is started

//animation for smooth transition from non expanded view to expanded view.

//here's a question for you. questions is spoken out.

//different voices for reading - explore. - best possible method using android.
//online tts - (download the audio and store in db) vs device tts.
//scroll automatically to follow highlighted text

//article read state should be maintained - add user activity to firebase


//tap to speak should be close to the mic button.

//if online - make request to LLM. - ques, summary, model ans send to LLM and check correctness.
//asses the answer for correctness.
//rate the ans on 1-10. response to give child whose given the ans.

//natural audio from tts. store in firebase.