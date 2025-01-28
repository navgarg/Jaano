import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';
import '../models/article_model.dart';
import '../services/riverpod_providers.dart';

class Carousel extends ConsumerWidget {
  const Carousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final carouselIndex = ref.watch(carouselIndexProvider);

    String getCategoryIcon(int index, WidgetRef ref) {
      final categoryManager = CategoryManager();
      final completionStatus = categoryManager.completionStatus(categories[index]);
      if (completionStatus == 0) return catIcons0[index];
      if (completionStatus == 1) return catIcons1[index];
      if (completionStatus == 2) return catIcons2[index];
      return catIcons3[index];
    }

    final scrollController = ScrollController(
      initialScrollOffset:
      carouselIndex * MediaQuery
          .of(context)
          .size
          .width * 0.28,
    );


    return SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.13,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        itemBuilder: (context, index) {
          final label = labels[index];
          final image = getCategoryIcon(index, ref);

          return GestureDetector(
            onTap: () {
              ref
                  .read(carouselIndexProvider.notifier)
                  .state = index;
              // articlesNotifier.fetchArticles(categories[carouselIndex]);

              // Scroll to the selected item with animation
              final offset =
                  index * MediaQuery
                      .of(context)
                      .size
                      .width * 0.24;
              scrollController.animateTo(
                offset,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.24,
              margin: const EdgeInsets.symmetric(horizontal: 4.0), //controls the spacing between successive elements in carousel


              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (carouselIndex ==
                          index) // Add shadow only for selected item
                        Container(
                          width: 58,
                          height: 58, //todo: convert this to percentage.
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.25), // Shadow color
                                blurRadius: 4.0, // Softness of shadow
                              ),
                            ],
                          ),
                        ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: Image.asset(
                            image,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: carouselIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
