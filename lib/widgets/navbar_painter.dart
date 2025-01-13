import 'package:flutter/material.dart';

import '../constants.dart';

/// Custom Clipper for the curve
class CurvedNavBarPainter extends CustomPainter {
  int index;
  CurvedNavBarPainter({required this.index});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(bgColors[index]).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5); // Start at the left-middle
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.2,
        size.width * 0.5, size.height * 0.5); // Create left curve
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.8, size.width, size.height * 0.5); // Create right curve
    path.lineTo(size.width, size.height); // Draw line to bottom-right
    path.lineTo(0, size.height); // Draw line to bottom-left
    path.close(); // Close the path

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}