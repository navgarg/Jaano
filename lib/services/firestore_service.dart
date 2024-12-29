

import 'package:cloud_firestore/cloud_firestore.dart' hide Source;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import 'article_api_service.dart';

class FirestoreService {

  CollectionReference ref = FirebaseFirestore.instance.collection("articles");
  String date = DateFormat("yyyy-MM-dd").format(DateTime.now());

  // String date = '18-11-2024';

  Future<List<Article>> getFirebaseArticles(Categories cat) async {
    // Categories cat = Categories.values.byName(category);
    print(cat);
    // print(category);
    print(date);
    print(ref);
    DocumentSnapshot snapshot = await ref.doc(date).get();
    QuerySnapshot<Map<String, dynamic>> articleSnapshot =
    await ref.doc(date).collection('arts').where("category", isEqualTo: cat.toString()).get();

    print("get articles");
    print(snapshot.data());

    print("Document path: ${ref.doc(date).path}");
    print("Arts collection path: ${ref.doc(date).collection('arts').path}");
    print("Source collection path: ${ref.doc(date).collection('arts').doc().collection('source').path}");
    print("Questions collection path: ${ref.doc(date).collection('arts').doc().collection('questions').path}");

    if (articleSnapshot.docs.isNotEmpty){
      print("exists");
      print(articleSnapshot.docs.toString());
      print(articleSnapshot.docs);

      List<Article> articles = [];
      for(var doc in articleSnapshot.docs){
        print("Processing article ID: ${doc.id}");
        QuerySnapshot<Map<String, dynamic>> sourceSnapshot =
        await ref.doc(date).collection('arts').doc(doc.id).collection('source').get();

        QuerySnapshot<Map<String, dynamic>> questionSnapshot =
        await ref.doc(date).collection('arts').doc(doc.id).collection('questions').get();

        List<Source> s = sourceSnapshot.docs.map((doc) => Source.fromFirestore(doc)).toList();
        List<Question> ques = questionSnapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();

        print(s);
        Source source = s[0];

        print(ques);
        articles.add(Article.fromFirestore(doc, source, ques));

      }

      print(articles[0].title);
      print(articles[1].title);
      print(articles[2].title);
      return articles;
    }

    else {
      ApiService client = ApiService();
      return client.getArticle(cat);
    }
    return [];
  }

  Future<void> addArticle(Article article) async {
    print("in add article");
    try {
      print("in try");
      DocumentReference dateDoc = ref.doc(date);
      DocumentReference articleDoc = await dateDoc.collection('arts').add(article.toMap());

      print("Added article");
      await articleDoc.collection('source').add(article.source.toMap());

      print("added source");
      for (var question in article.questions!) {
        await articleDoc.collection('questions').add(question.toMap());
      }
      print("added questions");

      print("Article added successfully!");
    } catch (e) {
      print("Error adding article: $e");
    }
  }
}
