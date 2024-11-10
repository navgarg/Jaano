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
  //todo: properly get question data from claude and update.
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

  factory Article.fromJson(Map<String, dynamic> json) {
    List<Categories> cats = Categories.values;
    Categories cat;
    if (cats.contains(json['category'])){
      cat = Categories.values.firstWhere((e) => e.toString() == 'Categories.' + json['category']);
    }
    else{
      cat = Categories.other;
    }
    return Article(
      source: Source.fromJson(json['source']),
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      content: json['content'],
      status: Status.incomplete,
      questions: [],
      category: cat, //todo: update wrt new json data
    );
  }
}