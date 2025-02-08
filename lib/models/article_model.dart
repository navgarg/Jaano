import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/claude_api_service.dart';

class ArticleSource{
  String name;
  String? id;

  ArticleSource({required this.id, required this.name});

  factory ArticleSource.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ArticleSource(id: data['id'] ?? "", name: data['name'] ?? "");
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
    };
  }

  factory ArticleSource.fromJson(Map<String, dynamic> json){
    return ArticleSource(id: json["id"], name: json["name"]);
  }
}

class Question{
  String question;
  String? answer;

  Question({required this.question, required this.answer});

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Question(question: data['question'] ?? "", answer: data['answer'] ?? "");
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json){
    return Question(question: json["question"], answer: json["answer"]);
  }
}
///predefined categories, to avoid confusion with strings
enum Categories {economy, technology, sports, science, food, nature, other;
}

class CategoryManager {
  final Map<Categories, int> _completionStatus = {
    for (var category in Categories.values) category: 0,
  };

  void addCompletedArticle(Categories category) {
    _completionStatus[category] = _completionStatus[category] != null ? _completionStatus[category]! + 1 : 1;
  }

  int? completionStatus(Categories category) {
    return _completionStatus[category];
  }

  void resetCompletion(Categories category) {
    _completionStatus[category] = 0;
  }
}

class Article {
  //todo: record activity of user in every session
  List<Question>? questions;
  ArticleSource source;
  String? author;
  Categories category;
  String title;
  String? description;
  String? url;
  String? urlToImage;
  final String id;
  String? publishedAt;
  String? content;
  bool isCompleted;
  Article(
      {required this.source,
        required this.author,
        required this.questions,
        required this.title,
        required this.category,
        required this.id,
        required this.description,
        required this.url,
        required this.urlToImage,
        required this.publishedAt,
        required this.content,
        required this.isCompleted,
      });

  factory Article.fromFirestore (DocumentSnapshot<Map<String, dynamic>> art, ArticleSource source, List<Question> questions){
    final data = art.data()!;
    Categories cat;
    try{
      cat = Categories.values.firstWhere((e) => e.toString() == 'Categories.' + data['category']);
    }
    catch (e) {
      cat = Categories.other;
    }

    return Article (
        source: source,
        id: data["id"] ?? art.id,
        author: data['author'] ?? "",
        questions: questions,
        title: data['title'] ?? "",
        category: cat,
        // status:,
        description: data['description'] ?? "",
        url: data['url'] ?? "",
        urlToImage: data['urlToImage'] ?? "",
        publishedAt: data['publishedAt'] ?? "",
        content: data['content'] ?? "",
        isCompleted: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'author': author,
      'category': category.toString(),
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
    };
  }

  Article copyWith({
    String? id,
    ArticleSource? source,
    String? author,
    String? title,
    String? description,
    String? url,
    String? urlToImage,
    String? publishedAt,
    String? content,
    List<Question>? questions,
    Categories? category,
    bool? isCompleted,
  }) {
    return Article(
      id: id ?? this.id,
      source: source ?? this.source,
      author: author ?? this.author,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      urlToImage: urlToImage ?? this.urlToImage,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      questions: questions ?? this.questions,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

    ///this method is only called if data for the day is not already present in firebase.
  static Future<Article> fromJson(Map<String, dynamic> json) async {
    Categories cat;
    try{
      cat = Categories.values.firstWhere((e) => e.toString() == 'Categories.' + json['category']);
    }
    catch (e) {
      cat = Categories.other;
    }

    String? resp = await getClaudeSummary(json['url'] as String);
    List<Question> quests = await getClaudeQuestions(resp);
    print(quests);
    print("run");

    return Article(
        source: ArticleSource.fromJson(json['source']),
        author: json['author'],
        title: json['title'],
        description: json['description'],
        url: json['url'],
        urlToImage: json['urlToImage'],
        publishedAt: json['publishedAt'],
        content: resp,
        id: const Uuid().v4(),
        // status: Status.incomplete,
        questions: quests,
        category: cat, //todo: update wrt new json data
        isCompleted: false
      );
    }
}



