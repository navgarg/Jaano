import 'dart:core';
import 'package:flutter/material.dart';

import 'models/article_model.dart';

class KColors {
  static const Color blue = Color(0xFF2977F5);
  static const Color primaryText = Color(0xFF456484);
  static const Color bodyText = Color(0xFF858585);
  static const Color border = Color(0x262977F5);
}

const String API_KEY = "4ec0bca1845443259827bcee48f9f1fe";
// const String baseUrl = "newsapi.org";
const String Claude_baseUrl = 'https://api.anthropic.com/v1/messages';
// const String newsUrl = "/v2/top-headlines";
const String baseUrl = "raw.githubusercontent.com";
const String newsUrl = "/navgarg/Loose-Files/master/jaano_newsdata.json";
final List<int> bgColors = [
  ///economy background color
  0xFF3EB99C,
  ///nature
  0xFFAFE4A8,
  ///food
  0xFFFEC863,
  ///science
  0xFF7EBBF1,
  ///sports
  0xFFEA9D9E,
  ///tech
  0xFFCFC4FF,
];
final List<String> homeBgImgs = [
  "assets/economy/eco_bg.png",
  "assets/nature/nat_bg.png",
  "assets/food/food_bg.png",
  "assets/science/sci_bg.png",
  "assets/sports/sport_bg.png",
  "assets/tech/tech_bg.png"
];
final List<String> expdBgImgs = [
  "assets/economy/eco_expanded_bg.png",
  "assets/nature/nat_expanded_bg.png",
  "assets/food/food_expanded_bg.png",
  "assets/science/sci_expanded_bg.png",
  "assets/sports/sport_expanded_bg.png",
  "assets/tech/tech_expanded_bg.png"
];
final catIcons0 = [
  "assets/economy/eco_3.png",
  "assets/nature/nat_3.png",
  "assets/food/food_3.png",
  "assets/science/sci_3.png",
  "assets/sports/sport_3.png",
  "assets/tech/tech_3.png"
];
final catIcons3 = [
  "assets/economy/eco_3.png",
  "assets/nature/nat_3.png",
  "assets/food/food_3.png",
  "assets/science/sci_3.png",
  "assets/sports/sport_3.png",
  "assets/tech/tech_3.png"
];
final catIcons2 = [
  "assets/economy/eco_2.png",
  "assets/nature/nat_2.png",
  "assets/food/food_2.png",
  "assets/science/sci_2.png",
  "assets/sports/sport_2.png",
  "assets/tech/tech_2.png"
];
final catIcons1 = [
  "assets/economy/eco_1.png",
  "assets/nature/nat_1.png",
  "assets/food/food_1.png",
  "assets/science/sci_1.png",
  "assets/sports/sport_1.png",
  "assets/tech/tech_1.png"
];
final List<String> quizIcons = [
  "assets/economy/eco_quiz.png",
  "assets/nature/nat_quiz.png",
  "assets/food/food_quiz.png",
  "assets/science/sci_quiz.png",
  "assets/sports/sport_quiz.png",
  "assets/tech/tech_quiz.png"
];
final List<String> diamondIcons = [
  "assets/economy/eco_diamond.png",
  "assets/nature/nat_diamond.png",
  "assets/food/food_diamond.png",
  "assets/science/sci_diamond.png",
  "assets/sports/sport_diamond.png",
  "assets/tech/tech_diamond.png"
];
final List<String> qpIcons = [
  "assets/economy/eco_qp.png",
  "assets/nature/nat_qp.png",
  "assets/food/food_qp.png",
  "assets/science/sci_qp.png",
  "assets/sports/sport_qp.png",
  "assets/tech/tech_qp.png"
];
final labels = ["Economy", "Nature", "Food", "Science", "Sports", "Tech"];
final categories = [
  Categories.economy,
  Categories.nature,
  Categories.food,
  Categories.science,
  Categories.sports,
  Categories.technology
];
