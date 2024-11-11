import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/article_model.dart';
import '../services/article_api_service.dart';
import '../services/claude_api_service.dart';
import '../widgets/article_tile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  // final TextEditingController _messageController = TextEditingController();
  // final ClaudeApiService _claudeService = ClaudeApiService(
  //   apiKey: dotenv.env['CLAUDE_API_KEY'] ?? " ", //todo: ??
  // );
  // List<Map<String, String>> messages = [];
  // bool isLoading = false;
  //
  // Future<void> _sendMessage() async {
  //   if (_messageController.text.isEmpty) return;
  //
  //   setState(() {
  //     messages.add({
  //       'role': 'user',
  //       'content': _messageController.text,
  //     });
  //     isLoading = true;
  //   });
  //
  //   try {
  //     final response = await _claudeService.sendMessage(
  //       content: _messageController.text, //todo: change prompt
  //     );
  //
  //     setState(() {
  //       messages.add({
  //         'role': 'assistant',
  //         'content': response['content'][0]['text'],
  //       });
  //       isLoading = false;
  //     });
  //
  //     _messageController.clear();
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     print("error");
  //     print(e);
  //     print("error");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }
  //
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Chat with Claude')),
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: ListView.builder(
  //             itemCount: messages.length,
  //             itemBuilder: (context, index) {
  //               final message = messages[index];
  //               return ListTile(
  //                 title: Text(message['content'] ?? ''),
  //                 leading: Icon(
  //                   message['role'] == 'user'
  //                       ? Icons.person
  //                       : Icons.smart_toy,
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //         if (isLoading)
  //           const Padding(
  //             padding: EdgeInsets.all(8.0),
  //             child: CircularProgressIndicator(),
  //           ),
  //         Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: TextField(
  //                   controller: _messageController,
  //                   decoration: const InputDecoration(
  //                     hintText: 'Type a message...',
  //                     border: OutlineInputBorder(),
  //                   ),
  //                 ),
  //               ),
  //               IconButton(
  //                 icon: const Icon(Icons.send),
  //                 onPressed: _sendMessage,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}