import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jaano/constants.dart';
import '../models/article_model.dart';

class ApiService {
  final client = http.Client();

  ///Make HTTP request and get news articles from API
  Future<List<Article>> getArticle() async {

    // final queryParameters = {
    //   'country': 'us',
    //   'category': 'technology',
    //   'apiKey': API_KEY,
    // };
    final uri = Uri.https(baseUrl, newsUrl);
    final response = await client.get(uri);
    var json = jsonDecode(response.body);
    // Map<String, dynamic> json = jsonDecode(response.body);
    List<dynamic> body = json['articles'];

    ///retrieve and store articles in list of type article.
    // List<Article> articles = List<Article>.from(body.map((e) async => await Article.fromJson(e)).toList());
    List<Article> articles = await Future.wait(body.map((e) async => Article.fromJson(e)).toList());
    return articles;
  }
}