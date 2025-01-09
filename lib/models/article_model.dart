import 'dart:convert';

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
// currently using ent, tech, sci, edu, sports, tourism
enum Categories {economy, technology, sports, science, food, nature, other
}

enum Status {complete, incomplete}

class Article {
  //record activity of user in every session
  List<Question>? questions;
  ArticleSource source;
  String? author;
  Categories category;
  // Status status;
  String title;
  String? description;
  String? url;
  String? urlToImage;
  String? publishedAt;
  String? content;
  bool isCompleted;
  Article(
      {required this.source,
        required this.author,
        required this.questions,
        required this.title,
        required this.category,
        // required this.status,
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
        // status: Status.incomplete,
        questions: quests,
        category: cat, //todo: update wrt new json data
        isCompleted: false
      );
    }
  }

Future<String> getClaudeSummary (String link) async {
  final ClaudeApiService claudeService = ClaudeApiService(
    apiKey: dotenv.env['CLAUDE_API_KEY'] ?? " ",
  );

  try {
    final response = await claudeService.sendMessage( //todo: make it easy to understand, atleast 120 words.
      content: "Summarize the news article given at the link: $link for a child in age group of 6-10 years. Use easy to understand language and short sentences. Make it engaging and interesting, while keeping all main points intact. Do not go over 4-5 lines. Do not include introductory line at the start.",
    );
    print(response);
    print(response['content']);
    String cont = response['content'][0]['text'].toString();
    return cont;

  } catch (e) {
    print("error while getting summary");
    print(e);
    print("error");
  }
  return "error";
}

Future<List<Question>> getClaudeQuestions(String content) async {
  final ClaudeApiService claudeService = ClaudeApiService(
    apiKey: dotenv.env['CLAUDE_API_KEY'] ?? " ",
  );

  try {
    final response = await claudeService.sendMessage(
      content: "Here is the summary of a news article meant for a child in age group of 6-10 years: $content Prepare two factual questions based on this summary. Include the answers to the questions too. Clearly demarcate every question and answer clearly.",
    );

    print("Response: $response");

    // Extract raw content from Claude's response
    String rawContent = response['content'][0]['text'].toString();

    // Split into non-empty lines
    List<String> lines = rawContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
    print("Lines: $lines");

    // Extract questions
    List<String> questions = lines
        .where((line) => line.startsWith('Question') || line.startsWith('Question'))
        .map((line) => line.substring(line.indexOf(':') + 1).trim()) // Remove "Question X: "
        .toList();
    print("Questions: $questions");

    // Extract answers
    List<String> answers = lines
        .where((line) => line.startsWith('Answer'))
        .map((line) => line.substring(line.indexOf(':') + 1).trim()) // Remove "Answer: "
        .toList();
    print("Answers: $answers");

    // Validate lengths
    if (questions.length != 2 || answers.length != 2) {
      throw Exception("Unexpected format: Could not find exactly two questions and answers.");
    }

    // Create a list of Question objects
    List<Question> questionList = [
      Question(question: questions[0], answer: answers[0]),
      Question(question: questions[1], answer: answers[1]),
    ];
    print("Parsed Questions: $questionList");

    return questionList;
  } catch (e) {
    print("Error while fetching questions: $e");
    return [];
  }
}

//todo:
//if no img, dont put generic
//mic animation to indicate listening mode and also show differently to show its getting voice
