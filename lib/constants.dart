import 'dart:core';
import 'package:flutter/material.dart';

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

final labels = ["Economy", "Nature", "Food", "Science", "Sports", "Tech"];
