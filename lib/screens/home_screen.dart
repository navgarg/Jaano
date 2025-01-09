import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/screens/expanded_article_screen.dart';
import 'package:jaano/widgets/bottom_navbar.dart';

import '../constants.dart';
import '../services/riverpod_providers.dart';
import '../widgets/shimmer_list_placeholder.dart';

//images

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
//todo:
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Watch providers
    final carouselIndex = ref.watch(carouselIndexProvider);
    final articlesAsync = ref.watch(articlesProvider);
    final expandedPanels = ref.watch(expandedPanelsProvider);

    final scrollController = ScrollController(
      initialScrollOffset:
          carouselIndex * MediaQuery.of(context).size.width * 0.28,
    );

    final List<String> bgImgs = [
      "assets/economy/eco_bg.png",
      "assets/nature/nat_bg.png",
      "assets/food/food_bg.png",
      "assets/science/sci_bg.png",
      "assets/sports/sport_bg.png",
      "assets/tech/tech_bg.png"
    ];

    final images = [
      "assets/economy/eco_3.png",
      "assets/nature/nat_3.png",
      "assets/food/food_3.png",
      "assets/science/sci_3.png",
      "assets/sports/sport_3.png",
      "assets/tech/tech_3.png"
    ];

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
              height: MediaQuery.of(context).size.height * 0.05,
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
              height: MediaQuery.of(context).size.height * 0.13,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final label = labels[index];
                  final image = images[index];

                  return GestureDetector(
                    onTap: () {
                      ref.read(carouselIndexProvider.notifier).state = index;

                      // Scroll to the selected item
                      final offset = index * MediaQuery.of(context).size.width * 0.24;
                      scrollController.animateTo(
                        offset,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.24,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0), ///controls the spacing between successive elements in carousel
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (carouselIndex == index) // Add shadow only for selected item
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25), // Shadow color
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
                              fontWeight:
                              carouselIndex == index ? FontWeight.bold : FontWeight.normal,
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
              child: articlesAsync.when(
                data: (articles) {
                  if (articles.isEmpty) {
                    return const Center(
                      child: Text('No articles available.'),
                    );
                  }

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
                              height: MediaQuery.of(context).size.height * 0.18,
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
                                                  article: article, index: carouselIndex,)));
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
          ]),
          const BottomNavbar(),
        ]),
      ),
      // bottomNavigationBar: const BottomNavbar(),
    );
  }
}

//on start listening, make overlay and mic animation.

//shared preference implement on first open (on bg?)
//heights in percentages? for sized boxes

//cache the imgs and stuff in shared preferences.
//record voices for tts and send for options.
//when reading stops unhighlight the word

//greyed and locked icons for other categories.
//other categories unlocked only by completing the prev category.
//when tech completed, economy is highlighted.
//rings are empty when new category is started
//shadow to highlight the category selected

//animation for smooth transition from non expanded view to expanded view.


//article read when tts completed.

//article points being added - animation? show something
//bottom bar use elements not image.

