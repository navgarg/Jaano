import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:jaano/models/article_model.dart';

class BottomNavbar extends StatelessWidget {
   const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(
                "243",
                textAlign: TextAlign.center,
              )),
          Expanded(flex: 1, child: Text("124", textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
