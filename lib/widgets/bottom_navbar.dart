import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaano/constants.dart';
import 'package:jaano/models/article_model.dart';
import 'package:jaano/widgets/points_container.dart';

import '../services/riverpod_providers.dart';
import 'navbar_painter.dart';

class BottomNavbar extends ConsumerWidget {
  int carouselIndex;
  BottomNavbar({super.key, required this.carouselIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(readingPointsProvider).totalPoints;
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.10, // Height of the nav bar
        child: Stack(
          children: [
            // Background curve
            CustomPaint(
              painter: CurvedNavBarPainter(index: carouselIndex),
              size: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height * 0.10,
              ),
            ),

            // Points containers and profile icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left points container
                PointsContainer(
                  icon: diamondIcons[carouselIndex],
                  points: points,
                  backgroundColor: Color(bgColors[carouselIndex]),
                ),

                // Profile Icon (centered)
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color(bgColors[carouselIndex])),
                  ),
                ),

                // Right points container
                PointsContainer(
                  icon: qpIcons[carouselIndex],
                  points: 300, // Static value for now
                  backgroundColor: Color(bgColors[carouselIndex]),
                ),
              ],
            ),
          ],
        ),
      ),
    );


  }
}