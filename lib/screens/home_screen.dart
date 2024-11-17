import 'package:flutter/material.dart';
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
  ApiService client = ApiService();

  List<bool> _isExpanded = [];
  Future<List<Article>>? _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = client.getArticle();
  }

  void _initializeExpansionStates(int length) {
    _isExpanded = List<bool>.filled(length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jaano'),
      ),
      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          else if (snapshot.hasData) {
            List<Article> articles = snapshot.data!;
            List<Article> techArticles = articles.where((art) => art.category == Categories.technology).toList();

            if (_isExpanded.isEmpty || _isExpanded.length != techArticles.length) {
              _initializeExpansionStates(techArticles.length);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              child: ListView(
                children: [
                  ExpansionPanelList(
                    expansionCallback: (int index, bool isExpanded) {
                      setState(() {
                        _isExpanded[index] = isExpanded;// Toggle the expansion state of the selected panel
                      });
                    },
                    children: techArticles.asMap().entries.map((entry) {
                      int index = entry.key;
                      Article article = entry.value;
              
                      return ExpansionPanel(
                        canTapOnHeader: true,
                        isExpanded: _isExpanded[index],
                        headerBuilder: (BuildContext ctx, bool isExp) {
                          return ListTile(
                            title: Text(
                                article.title,
                              style: const TextStyle(
                                fontSize: 16.0,
                                color: KColors.primaryText
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
                                  color: KColors.bodyText
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  onPressed: () { //todo: update by getting question data from LLM.
                                    showDialog(
                                        context: context,
                                        builder: (context) => QuizDialog(title: "Quiz", content: article.content ?? "")
                                    );
                                  },
                                  child: Text("Start Quiz"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No articles found.'));
        },
      ),
    );
  }
}
