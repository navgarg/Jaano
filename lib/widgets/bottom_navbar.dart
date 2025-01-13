import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:jaano/constants.dart';
import 'package:jaano/models/article_model.dart';

class BottomNavbar extends StatelessWidget {
  int carouselIndex;
  BottomNavbar({super.key, required this.carouselIndex});

  @override
  Widget build(BuildContext context) {

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
                Container(
                  margin: const EdgeInsets.only(left: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(bgColors[carouselIndex]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Image.asset(diamondIcons[carouselIndex]),
                      const SizedBox(width: 5),
                      const Text('1200', style: TextStyle(color: Colors.white)),
                    ],
                  ),
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
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(bgColors[carouselIndex]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Image.asset(qpIcons[carouselIndex]),
                      const SizedBox(width: 5),
                      Text('300', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );


  }
}

// Custom Clipper for the curve
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