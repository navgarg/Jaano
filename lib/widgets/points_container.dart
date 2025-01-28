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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: Colors.black, // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(icon),
          const SizedBox(width: 5),
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
