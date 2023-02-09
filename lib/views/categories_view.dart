import 'package:flutter/material.dart';
import 'package:mynotes/constants/note_categories.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/widgets/custom_category_item.dart';
import 'package:mynotes/utilities/widgets/custom_floating_action_button.dart';
import 'package:mynotes/views/category_view.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  late final FirebaseCloudStorageService _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorageService();
    super.initState();
  }

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
                          return StreamBuilder<Object>(
                            stream: _notesService.allNotes(ownerUserId: userId),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                case ConnectionState.active:
                                  if (snapshot.hasData) {
                                    final allNotes =
                                        snapshot.data as Iterable<CloudNote>;
                                    final noteCategoryCount = allNotes
                                        .toList()
                                        .where(
                                          (note) => note.category == category,
                                        )
                                        .length;
                                    return GestureDetector(
                                      onTap: (() {
                                        Navigator.of(context).pushNamed(
                                          CategoryView.routeName,
                                          arguments: category,
                                        );
                                      }),
                                      child: CustomCategoryItem(
                                        categoryColor: categoryColor,
                                        category: category,
                                        noteCount: noteCategoryCount,
                                      ),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                default:
                                  return const CircularProgressIndicator();
                              }
                            },
                          );
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
    print("new category dialog"); //TODO: add new category, store and retrieve it
  }
}
