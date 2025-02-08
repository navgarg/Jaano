import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import 'article_api_service.dart';

enum PointType{quizPoints, articlePoints}
class FirestoreService {

  CollectionReference ref = FirebaseFirestore.instance.collection("articles");
  String date = DateFormat("yyyy-MM-dd").format(DateTime.now());
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getUserPoints(String userId, PointType type) async {
    try {
      DocumentSnapshot snapshot = await _db
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.cache)); // Load from cache first

      if (!snapshot.exists) {
        snapshot = await _db
            .collection('users')
            .doc(userId)
            .get(const GetOptions(source: Source.server)); // Fetch from Firestore
      }

      print("type");
      print(type.toString());
      return snapshot.exists ? (snapshot[type.toString()] as int) : 0;
    } catch (e) {
      print("Error fetching points: $e");
      return 0;
    }
  }

  // Update user points in Firestore
  Future<void> updateUserPoints(String userId, int newPoints, PointType type) async {
    await _db.collection('users').doc(userId).update({type.toString(): newPoints});
  }

  // Listen to real-time points updates
  Stream<int> streamUserPoints(String userId, PointType type) {
    return _db.collection('users').doc(userId).snapshots().map(
            (snapshot) => snapshot.exists ? (snapshot[type.toString()] as int) : 0);
  }

  Future<List<Article>> getFirebaseArticles(Categories cat) async {
    // Categories cat = Categories.values.byName(category);
    print(cat);
    // print(category);
    print(date);
    print(ref);
    DocumentSnapshot snapshot = await ref.doc(date).get();
    QuerySnapshot<Map<String, dynamic>> articleSnapshot =
    await ref.doc(date).collection('arts').where("category", isEqualTo: cat.toString()).get(const GetOptions(source: Source.cache));

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
        await ref.doc(date).collection('arts').doc(doc.id).collection('source').get(const GetOptions(source: Source.cache));

        QuerySnapshot<Map<String, dynamic>> questionSnapshot =
        await ref.doc(date).collection('arts').doc(doc.id).collection('questions').get(const GetOptions(source: Source.cache));

        List<ArticleSource> s = sourceSnapshot.docs.map((doc) => ArticleSource.fromFirestore(doc)).toList();
        List<Question> ques = questionSnapshot.docs.map((doc) => Question.fromFirestore(doc)).toList();

        print(s);
        ArticleSource source = s[0];

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
  }

  Future<void> addArticle(Article article) async {
    print("in add article");
    try {
      print("in try");
      DocumentReference dateDoc = ref.doc(date);
      DocumentReference articleDoc = await dateDoc.collection('arts').add(article.toMap());
      String articleId = articleDoc.id;
      await articleDoc.update({"id": articleId});

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

  Future<void> logUserAction(String userId, String actionType, {Map<String, dynamic>? extraData}) async {
    String date = DateTime.now().toLocal().toString().split(' ')[0]; // Get YYYY-MM-DD
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    Map<String, dynamic> logEntry = {
      "timestamp": FieldValue.serverTimestamp(),
      "action": actionType,
      "extraData": extraData ?? {},
    };

    await _db.collection('users').doc(userId)
        .collection('activity').doc(date) // Create a document for the day
        .collection('events').doc(timestamp) // Store logs inside "events"
        .set(logEntry);
  }

  Future<List<String>> getCompletedArticles(String userId) async {
    String date = DateTime.now().toLocal().toString().split(' ')[0]; // YYYY-MM-DD
    List<String> completedArticles = [];

    QuerySnapshot logSnapshots = await _db
        .collection('users')
        .doc(userId)
        .collection('activity')
        .doc(date)
        .collection('events')
        .where("action", isEqualTo: "article_completed")
        .get();

    for (var doc in logSnapshots.docs) {
      completedArticles.add((doc['extraData'] as Map<String, dynamic>?)?['articleId']); // Assuming articleId is stored in logs
    }

    return completedArticles;
  }

}
