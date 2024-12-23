import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jaano/services/firestore_service.dart';
import 'package:jaano/widgets/QuizDialog.dart';
import '../constants.dart';
import '../models/article_model.dart';
import '../services/article_api_service.dart';
import '../services/claude_api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  FirestoreService client = FirestoreService();

  final FlutterTts flutterTts = FlutterTts();

  List<bool> _isExpanded = [];
  Future<List<Article>>? _articlesFuture;

  @override
  void initState() {
    super.initState();
    //todo: update with every tab for every category
    _articlesFuture = client.getFirebaseArticles(Categories.technology);
    flutterTts.setLanguage('en-US'); //todo: set language after getting from device (?)
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.2);
  }

  void _initializeExpansionStates(int length) {
    _isExpanded = List<bool>.filled(length, false);
  }

  void tts (String? content) async {
    await flutterTts.speak(content ?? "");

  }

  final List<Map<String, String>> items = [
    {'imagePath':'assets/economy.png', 'label':'Economy'},
    {'imagePath':'assets/environment.png', 'label':'Nature'},
    {'imagePath':'assets/food.png', 'label':'Food'},
    {'imagePath':'assets/science.png', 'label':'Science'},
    {'imagePath':'assets/sports.png', 'label':'Sports'},
    {'imagePath':'assets/tech/tech_3.png', 'label':'Technology'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Jaano'),
      // ),
      body: SafeArea(
        child: Stack(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/tech/tech_bg.png"), fit: BoxFit.cover,),
              ),
            ),
            Column(
              children: [
                CarouselSlider.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index, realIndex) {
                    final item = items[index];
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: Image.asset(
                              item['imagePath']!,
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['label']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 180, // Adjust height for circle and text
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.3,
                    onPageChanged: (index, reason) {
                      //todo: implement on page change
                      print("Current page: $index");
                    },
                  ),
                ),
          
                const SizedBox(height: 10.0),
          
                Expanded(
                  child: FutureBuilder<List<Article>>(
                  future: _articlesFuture,
                  builder: (context, snapshot) {
                    print("in builder.");
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      print("waiting");
                      return const Center(child: CircularProgressIndicator());
                    }
                    else if (snapshot.hasError) {
                      print("error in builder");
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    else if (snapshot.hasData) {
                      print("snap has data");
                      List<Article> articles = snapshot.data!;
                      print(articles);
                      // List<Article> techArticles = articles.where((art) => art.category == Categories.technology).toList();
                  
                      if (_isExpanded.isEmpty || _isExpanded.length != articles.length) {
                        _initializeExpansionStates(articles.length);
                      }
                  
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        child: ListView.builder(
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            Article article = articles[index];
                            return Column(
                              children: [
                                ExpansionPanelList(
                                  expansionCallback: (int panelIndex, bool isExpanded) {
                                    setState(() {
                                      _isExpanded[index] = !_isExpanded[index];
                                    });
                                  },
                                  elevation: 1,
                                  children: [
                                    ExpansionPanel(
                                      canTapOnHeader: true,
                                      isExpanded: _isExpanded[index],
                                      backgroundColor: const Color(0xFFB1A1FC),
                                      headerBuilder: (BuildContext ctx, bool isExp) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: ListTile(
                                            leading: Image.asset('assets/circuit.png'),
                                            title: Text(
                                              article.title,
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      body: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              article.content ?? '',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => QuizDialog(article: article),
                                                  );
                                                },
                                                child: const Text("Start Quiz"),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomLeft,
                                              child: TextButton(
                                                onPressed: () {
                                                  tts(article.content);
                                                },
                                                child: const Text("Read"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Add spacing below each panel
                                const SizedBox(height: 16.0),
                              ],
                            );
                          },
                        ),
                      );
                    }
                    return const Center(child: Text('No articles found.'));
                  },
                            ),
                ),
              ]
            ),
          ]
        ),
      ),
    );
  }
}
