import 'package:flutter/material.dart';
import 'package:jaano/models/article_model.dart';

import '../constants.dart';

class ArticleTile extends StatelessWidget {

  final Article article;

  const ArticleTile({
    super.key,
    required this.article
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.center,
          leading: Image.asset('assets/circuit.png'),
          title: Text(article.title,
            style: const TextStyle(
              fontSize: 16,
              color: KColors.primaryText,
            ),),
          subtitle: article.description !=null
              ? Text(
            article.description!,
            style: const TextStyle(
              color: KColors.bodyText,
              fontSize: 13.0,
            )
          )
            : const Text (
            "" //todo: verify this.
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
                color: KColors.border, width: 1),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
