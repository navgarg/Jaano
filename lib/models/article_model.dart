import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../services/claude_api_service.dart';

class Source{
  String name;
  String? id;

  Source({required this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json){
    return Source(id: json["id"], name: json["name"]);
  }
}
class Question{
  String question;
  String? answer;

  //todo: use claude to get question and send response to check ans.
  Question({required this.question, required this.answer});

  factory Question.fromJson(Map<String, dynamic> json){
    return Question(question: json["question"], answer: json["answer"]);
  }
}
///predefined categories, to avoid confusion with strings
// currently using ent, tech, sci, edu, sports, tourism
enum Categories {domestic, education, entertainment, environment, food,
  health, lifestyle, other, politics, science, sports, technology, top, tourism, world, business
}

enum Status {complete, incomplete}

class Article {
  //record activity of user in every session
  List<Question>? questions;
  Source source;
  String? author;
  Categories category;
  Status status;
  String title;
  String? description;
  String? url;
  String? urlToImage;
  String? publishedAt;
  String? content;
  Article(
      {required this.source,
        required this.author,
        required this.questions,
        required this.title,
        required this.category,
        required this.status,
        required this.description,
        required this.url,
        required this.urlToImage,
        required this.publishedAt,
        required this.content});

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
    print("run");

    return Article(
        source: Source.fromJson(json['source']),
        author: json['author'],
        title: json['title'],
        description: json['description'],
        url: json['url'],
        urlToImage: json['urlToImage'],
        publishedAt: json['publishedAt'],
        content: resp,
        status: Status.incomplete,
        questions: [],
        category: cat, //todo: update wrt new json data
      );
    }
  }

Future<String> getClaudeSummary (String link) async {
  final ClaudeApiService claudeService = ClaudeApiService(
    apiKey: dotenv.env['CLAUDE_API_KEY'] ?? " ",
  );

  try {
    final response = await claudeService.sendMessage(
      content: "Summarize the news article given at the link: $link for a child in age group of 6-10 years. Use easy to understand language and short sentences. Make it engaging and interesting, while keeping all main points intact. Do not go over 4-5 lines. Do not include introductory line at the start.", //todo: change prompt
    );
    print(response);
    print(response['content']);
    String cont = response['content'][0]['text'].toString();
    return cont;

  } catch (e) {
    print("error in model");
    print(e);
    print("error");
  }
  return "error";
}

//voice interaction with claude
//database