import 'package:flutter/material.dart';
import 'package:jaano/models/article_model.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerImgPlaceholder extends StatelessWidget {
  Article article;
  ShimmerImgPlaceholder({required this.article, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Stack(
          children: [
            /// Shimmer effect
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 200.0,
                color: Colors.grey.shade300,
              ),
            ),
            // Actual image
            Image.network(
              article.urlToImage.toString(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; /// Show the image once it's loaded
                }
                return Container(); /// Keep showing the shimmer effect while loading
              },
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  'Error loading image',
                  style: TextStyle(color: Colors.red),
                ); /// Handle errors gracefully
              },
            ),
          ],
        ),
      ),
    );
  }
}
