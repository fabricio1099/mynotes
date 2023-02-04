import 'package:flutter/material.dart';
import 'package:mynotes/constants/note_categories.dart';
import 'package:mynotes/utilities/widgets/custom_category.dart';
import 'package:mynotes/utilities/widgets/custom_floating_action_button.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: CustomFloatingActionButton(
          context: context,
          onPressed: openNewCategoryDialog,
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Categories',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: noteCategories.length,
                        itemBuilder: (context, index) {
                          final category = noteCategories.keys.elementAt(index);
                          final categoryColor =
                              noteCategories[category]!['colorHex'] as int;
                          return CustomCategory(
                              categoryColor: categoryColor, category: category);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void openNewCategoryDialog() {
    print("new category dialog");//TODO: add new category, store and retrieve it
  }
}
