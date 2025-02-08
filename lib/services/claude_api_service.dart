import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/article_model.dart';

class ClaudeApiService {
  final String apiKey;

  ClaudeApiService({required this.apiKey});

  Future<Map<String, dynamic>> sendMessage({
    required String content,
    String model="claude-3-sonnet-20240229",
    // String model = 'claude-3-opus-20240229',
    double temperature = 1.0, //controls randomness of responses - higher values will give more creative and diverse responses. lower values will give focused responses.
    int? maxTokens,
  }) async {
    try {
      final headers = {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      };

      final body = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': content,
          }
        ],
        'temperature': temperature,
        'max_tokens': maxTokens ?? 500,
        'system':"You are a helpful assistant that specializes in explaining news to children."
      };

      final response = await http.post(
        Uri.parse(Claude_baseUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

}

Future<String> getClaudeSummary (String link) async {
  final ClaudeApiService claudeService = ClaudeApiService(
    apiKey: dotenv.env['CLAUDE_API_KEY'] ?? " ",
  );

  try {
    final response = await claudeService.sendMessage(
      content: "Summarize the news article given at the link: $link for a child in age group of 6-10 years. "
          "Use easy to understand language and short sentences. "
          "Make it engaging and interesting, while keeping all main points intact. "
          "Do not go over 5-6 lines, however let it be at least 120 words. "
          "Do not include introductory line at the start.",
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
      content: "Here is the summary of a news article meant for a child in age group of 6-10 years: $content "
          "Prepare two factual questions based on this summary. "
          "Include the answers to the questions too. "
          "Clearly demarcate every question and answer clearly.",
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

Future<List<dynamic>> checkClaudeAnswer (Article article, String ans, int quesIndex) async {
  final ClaudeApiService claudeService = ClaudeApiService(
    apiKey: dotenv.env['CLAUDE_API_KEY'] ?? " ",
  );
  print("ans");
  print(ans);
  print("ans");

  // if(ans.isEmpty){
  //   return ["Please provide an answer", "0"];
  // }

  try {
    final response = await claudeService.sendMessage(
      content: "Here is the summary of a news article meant for a child in age group of 6-10 years: ${article.content}. "
          "Based on this article, the question is: ${article.questions![quesIndex].question}. "
          "The answer model to this question is: ${article.questions![quesIndex].answer}. "
          "The child's answer is: $ans. Rate this answer on a scale of 1-10 based on correctness and clarity in the format \"Rating: \"."
          "Also provide feedback to the child in the format: \"Feedback to the child: \"",
    );
    print(response);
    String rawContent = response['content'][0]['text'].toString();
    print(rawContent);
    List<String> lines = rawContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
    print(lines);
    String rating = lines
        .where((line) => line.startsWith('Rating'))
        .map((line) => line.substring(line.indexOf(':') + 1).trim()).toString();
    rating = rating.replaceAll("(", "");
    rating = rating.replaceAll(")", "");

    print(rating);
    int? rat = int.tryParse(rating);
    rat ??= 0;
    print(rat);

    print(rating);
    String feedback = lines
        .where((line) => line.startsWith('Feedback to the child'))
        .map((line) => line.substring(line.indexOf(':') + 1).trim()).toString();
    print(feedback);

    feedback ??= "";

    feedback = feedback.replaceAll("(", "");
    feedback = feedback.replaceAll(")", "");

    return [feedback, rat];

  } catch (e) {
    print("error while getting answer response");
    print(e);
    print("error");
  }
  return ["error"];
}
