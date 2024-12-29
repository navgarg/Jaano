import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/services/firestore_service.dart';
import 'package:jaano/screens/expanded_article_screen.dart';
import '../constants.dart';
import '../models/article_model.dart';
import '../services/article_api_service.dart';
import '../services/claude_api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/riverpod_providers.dart';

//images

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final carouselIndex = ref.watch(carouselIndexProvider);
    final articlesAsync = ref.watch(articlesProvider);
    final expandedPanels = ref.watch(expandedPanelsProvider);


    final FlutterTts flutterTts = FlutterTts();
    flutterTts.setLanguage('en-US');
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.2);

    void tts(String? content) async {
      await flutterTts.speak(content ?? "");
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/tech/tech_bg.png"), fit: BoxFit.cover,),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 20.0,),
                SizedBox(
                  height: 50.0,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: (){

                          },
                            icon: const ImageIcon(AssetImage("assets/prev_date.png"))
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
                            onPressed: (){

                            },
                            icon: const ImageIcon(AssetImage("assets/next_date.png"))
                        ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                CarouselSlider.builder(
                  itemCount: 6,
                  itemBuilder: (context, index, realIndex) {
                    final label = ["Economy", "Nature", "Food", "Science", "Sports", "Tech"][index];
                    final image = ["assets/economy.png", "assets/environment.png", "assets/food.png", "assets/science.png", "assets/sports.png", "assets/tech/tech_3.png"][index];
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: Image.asset(
                              // item['imagePath']!,
                              image, //todo: update with every cat
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: carouselIndex == index ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 100, // Adjust height for circle and text
                    autoPlay: false,
                    enlargeCenterPage: false,
                    viewportFraction: 0.28,
                    onPageChanged: (index, reason) {
                      ref.read(carouselIndexProvider.notifier).state = index;
                    },
                  ),
                ),
          
                // const SizedBox(height: 10.0),
                Expanded(
                  child: articlesAsync.when(
                    data: (articles) {
                      if (articles.isEmpty) {
                        return const Center(
                          child: Text('No articles available.'),
                        );
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (expandedPanels.isEmpty || expandedPanels.length != articles.length) {
                          ref.read(expandedPanelsProvider.notifier).initialize(articles.length);
                        }
                      });
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        child: ListView.builder(
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            final article = articles[index];
                            // final isExpanded = expandedPanels[index];

                            return Column(
                              children: [
                                ExpansionPanelList(
                                elevation: 0,
                                expansionCallback: (panelIndex, isExpanded) {
                                  ref.read(expandedPanelsProvider.notifier).togglePanel(index);
                                },
                                // expansionCallback: (panelIndex, isExpanded) {
                                //   ref.read(expandedPanelsProvider.notifier).state =
                                //       List.generate(
                                //         expandedPanels.length,
                                //             (i) => i == index ? !expandedPanels[i] : false,
                                //       );
                                // },
                                children: [
                                  ExpansionPanel(
                                    splashColor: const Color(0xFFB1A1FC),
                                    canTapOnHeader: true,
                                    isExpanded: (index < expandedPanels.length) ? expandedPanels[index] : false,
                                    backgroundColor: Colors.transparent,
                                    headerBuilder: (context, isExpanded) => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            const Color(0xFFB1A1FC).withOpacity(1.0), // Start with solid color
                                            const Color(0xFFB1A1FC).withOpacity(0.0), // End with transparent
                                          ],
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: ListTile(
                                        leading: Image.asset('assets/circuit.png'),
                                        title: Text(
                                          article.title,
                                          style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    body: Container(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              const Color(0xFFB1A1FC).withOpacity(1.0),
                                              const Color(0xFFB1A1FC).withOpacity(0.0),
                                            ],
                                          ),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              article.description ?? '',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => ExpandedArticleScreen(article: article)),
                                                    // builder: (context) => QuizDialog(article: article),
                                                  );
                                                },
                                                child: const Text("Read More"),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomLeft,
                                              child: TextButton(
                                                onPressed: () {
                                                  tts(article.description);
                                                },
                                                child: const Text("Read Aloud"),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                              ),
                            // Add spacing below each panel
                            const SizedBox(height: 16.0),
                            ]
                            );

                          },
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ]
            ),
          ]
        ),
      ),
      bottomNavigationBar: Container(
        height: 100.0,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/tech/bottom.png'), // Replace with your image path
            fit: BoxFit.cover, // Adjust how the image fits the container
          ),
          borderRadius: BorderRadius.circular(15), // Optional: Rounded corners
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Image.asset("assets/tech/Diamond.png")
            ),
            Expanded(
                flex: 1,
                child: Image.asset("assets/tech/Diamond.png")
            ),
          ],
        ),
      ),
    );
  }
}
