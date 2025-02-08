import 'package:flutter/material.dart';

class PointsContainer extends StatelessWidget {
  final String icon;
  final int points;
  final Color backgroundColor;

  const PointsContainer({super.key,
    required this.icon,
    required this.points,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.055,
      width: MediaQuery.of(context).size.width * 0.3,
      margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: Colors.white, // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
              icon,
              height: 40,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: points),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Text(
                '$value',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
