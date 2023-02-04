import 'package:flutter/material.dart';
import 'package:mynotes/constants/note_categories.dart';

class CustomCategory extends StatelessWidget {
  const CustomCategory({
    Key? key,
    required this.categoryColor,
    required this.category,
  }) : super(key: key);

  final int categoryColor;
  final String category;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(categoryColor),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 0.4,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Expanded(
            child: Icon(noteCategories[category]!['icon'] as IconData),
          ),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          const Text(
            '5 files', // TODO: display real count of notes for specific category
            style: TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
