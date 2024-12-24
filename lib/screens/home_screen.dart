import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:jaano/services/firestore_service.dart';
import 'package:jaano/widgets/QuizDialog.dart';
import 'package:jaano/widgets/article_expanded_view.dart';
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
//reduce gap
//start quiz on next screen - expanded view - //todo: will this be a dialog or new screen?
//highlight the text that is being read
//press read => player mode of article
//font change
//script to convert news to json as needed



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
                    height: 100, // Adjust height for circle and text
                    autoPlay: false,
                    enlargeCenterPage: false,
                    viewportFraction: 0.28,
                    onPageChanged: (index, reason) {
                      //todo: implement on page change with riverpod
                      print("Current page: $index");
                    },
                  ),
                ),
          
                // const SizedBox(height: 10.0),
          
                Expanded(
                  flex: 1,
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
                                  elevation: 0,
                                  children: [
                                    ExpansionPanel(
                                      splashColor: const Color(0xFFB1A1FC),
                                      canTapOnHeader: true,
                                      isExpanded: _isExpanded[index],
                                      backgroundColor: Colors.transparent,
                                      headerBuilder: (BuildContext ctx, bool isExp) {
                                        return Container(
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
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      body: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              const Color(0xFFB1A1FC).withOpacity(1.0),
                                              const Color(0xFFB1A1FC).withOpacity(0.0),
                                            ],
                                          )
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
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => ExpandedArticle(article: article),
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
