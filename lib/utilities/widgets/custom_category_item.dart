import 'package:flutter/material.dart';
import 'package:mynotes/constants/note_categories.dart';

class CustomCategoryItem extends StatelessWidget {
  const CustomCategoryItem({
    Key? key,
    required this.categoryColor,
    required this.category,
    required this.noteCount,
  }) : super(key: key);

  final int categoryColor;
  final String category;
  final int noteCount;

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
          Text(
            noteCount > 1 ? '$noteCount files' : '$noteCount file',
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
