import 'package:flutter/material.dart';

import '../constants.dart';

class CategoryHeader extends StatefulWidget {
  final int index;
  const CategoryHeader({super.key, required this.index});

  @override
  State<CategoryHeader> createState() => _CategoryHeaderState();
}

class _CategoryHeaderState extends State<CategoryHeader> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                )),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 5.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: Color(categoryHeaderColors[widget.index]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                labels[widget.index],
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.transparent,
                )),
          ),
        ],
      ),
    );
  }
}
