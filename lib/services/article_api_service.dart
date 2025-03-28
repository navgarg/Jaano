import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jaano/constants.dart';
import 'package:jaano/services/firestore_service.dart';
import '../models/article_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  final client = http.Client();
  static bool _isFetching = false;

  ///Make HTTP request and get news articles from API
  Future<List<Article>> getArticle(Categories cat) async {
    if (_isFetching) {
      print("Request already in progress. Returning.");
      return []; // Prevent multiple requests
    }

    _isFetching = true; // Set flag to indicate request is in progress
    print("Fetching articles from API...");


    try{
    final uri = Uri.https(baseUrl, newsUrl);
    final response = await client.get(uri);
    var json = jsonDecode(response.body);
    // Map<String, dynamic> json = jsonDecode(response.body);
    List<dynamic> body = json['results'];

    print(body);
    ///retrieve and store articles in list of type article.
    // List<Article> articles = List<Article>.from(body.map((e) async => await Article.fromJson(e)).toList());
    List<Article> articles = await Future.wait(body.map((e) async => Article.fromJson(e)).toList());

    for (var art in articles) {
      FirestoreService service = FirestoreService();
      service.addArticle(art);
    }

    List<Article> arts = articles.where((art) => art.category == cat).toList();
    print("article rcvd successfully");
    print(arts);
    return arts;
    } catch (e) {
      print("Error fetching articles: $e");
      return [];
    } finally {
      _isFetching = false; // Reset flag after request completes
    }
  }
}