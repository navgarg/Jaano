import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jaano/constants.dart';
import 'package:jaano/models/article_model.dart';
import 'package:jaano/widgets/navbar/points_container.dart';

import '../../services/riverpod_providers.dart';
import 'navbar_painter.dart';

class BottomNavbar extends ConsumerWidget {
  int carouselIndex;
  BottomNavbar({super.key, required this.carouselIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingPoints = ref.watch(readingPointsProvider("user.id")).totalPoints; //todo: change user id
    final quizPoints = ref.watch(quizPointsProvider("user.id")).totalPoints; //todo: change user id

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.11, // Height of the nav bar
        // child: Stack(
        //   children: [
        //     // Background curve
        //     CustomPaint(
        //       painter: CurvedNavBarPainter(index: carouselIndex),
        //       size: Size(
        //         MediaQuery.of(context).size.width,
        //         MediaQuery.of(context).size.height * 0.10,
        //       ),
        //     ),

        child: Container(
          decoration: BoxDecoration(
            color: Color(bgColors[carouselIndex]).withOpacity(0.78),
            borderRadius: BorderRadius.circular(10.0),
          ),
          
          child: 
            // Points containers and profile icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left points container
                PointsContainer(
                  icon: diamondIcons[carouselIndex],
                  points: readingPoints,
                  backgroundColor: Color(bgColors[carouselIndex]),
                ),

                // Profile Icon (centered)
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.5), // Shadow color
                          blurRadius: 8.0, // Softness of shadow
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Color(bgColors[carouselIndex])),
                    ),
                  ),
                ),

                // Right points container
                PointsContainer(
                  icon: qpIcons[carouselIndex],
                  points: quizPoints,
                  backgroundColor: Color(bgColors[carouselIndex]),
                ),
              ],
            ),
          // ],
          // )
        ),
      ),
    );


  }
}