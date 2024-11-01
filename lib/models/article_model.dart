class Source{
  String name;
  String? id;

  Source({required this.id, required this.name});

  factory Source.fromJson(Map<String, dynamic> json){
    return Source(id: json["id"], name: json["name"]);
  }
}

class Article {
  Source source;
  String? author;
  String title;
  String? description;
  String? url;
  String? urlToImage;
  String? publishedAt;
  String? content;
  Article(
      {required this.source,
        required this.author,
        required this.title,
        required this.description,
        required this.url,
        required this.urlToImage,
        required this.publishedAt,
        required this.content});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source.fromJson(json['source']),
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
      content: json['content'],
    );
  }
}