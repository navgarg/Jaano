import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';
import '../widgets/article_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  ApiService client = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            "Jaano: Kids' News of the World",
          style: TextStyle(
              color: KColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
          future: client.getArticle(),
          builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot){
            if (snapshot.hasData){
              List<Article>? articles = snapshot.data;
              return ListView.builder(
                  itemCount: articles?.length,
                itemBuilder: (context, index) => ArticleTile(article: articles![index])

                // itemBuilder: (context, index) => ArticleTile(article: articles![index])
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );

          },
      ),
    );
  }
}