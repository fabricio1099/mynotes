import 'package:flutter/material.dart';
import 'package:mynotes/constants/note_categories.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/utilities/widgets/custom_floating_action_button.dart';
import 'package:mynotes/utilities/widgets/custom_note_item.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';

class CategoryView extends StatefulWidget {
  static const routeName = '/view-category';

  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late final FirebaseCloudStorageService _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorageService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final category = context.getArgument<String>();
    return Scaffold(
      floatingActionButton: CustomFloatingActionButton(
        context: context,
        onPressed: () {
          Navigator.of(context)
              .pushNamed(CreateUpdateNoteView.routeName, arguments: category);
        },
      ),
      appBar: AppBar(
        leadingWidth: 40,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 17,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        '$category notes',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(noteCategories[category]!['icon'] as IconData),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  StreamBuilder<Object>(
                    stream: _notesService.allNotes(ownerUserId: userId),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          if (snapshot.hasData) {
                            final allNotes =
                                snapshot.data as Iterable<CloudNote>;
                            final notesFromCategory = allNotes
                                .where((note) => note.category == category);
                            if (notesFromCategory.isEmpty) {
                              return SizedBox(
                                height: constraints.maxHeight * 0.5,
                                width: constraints.maxWidth * 0.5,
                                child: const Image(
                                  image: AssetImage('assets/image/empty.jpg'),
                                ),
                              );
                            }
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                  maxHeight: constraints.maxHeight),
                              child: ListView.builder(
                                itemCount: notesFromCategory.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomNoteItem(
                                        note:
                                            notesFromCategory.elementAt(index),
                                        displayCategoryChip: false,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        default:
                          return const CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
