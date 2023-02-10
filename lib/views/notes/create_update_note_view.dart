import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/constants/date_formatter.dart';
import 'package:mynotes/constants/note_categories.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';

class CreateUpdateNoteView extends StatefulWidget {
  static const routeName = '/create-update-note';

  const CreateUpdateNoteView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorageService _notesService;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;
  bool _isPinned = false;
  bool _isFavourite = false;
  Timestamp? _pinnedDate;
  Timestamp? _favouriteDate;
  String _selectedNoteCategory =
      noteCategories.keys.firstWhere((key) => key == "Random");
  bool _wasNoteUpdated = false;

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleController.text = widgetNote.title;
      _isPinned = widgetNote.isPinned;
      _isFavourite = widgetNote.isFavourite;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final newNote = CloudNote(
      documentId: CloudNote.initialNoteDocumentId,
      ownerUserId: currentUser.id,
      text: '',
      title: '',
      createdDate: Timestamp.now(),
      modifiedDate: Timestamp.now(),
      category: _selectedNoteCategory,
    );
    _note = newNote;
    return newNote;
  }

  void _saveNoteIfTextOrTitleNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleController.text;
    if (note != null && (text.isNotEmpty || title.isNotEmpty)) {
      final currentUser = AuthService.firebase().currentUser!;
      final String documentId = await _notesService.saveNote(
        ownerUserId: currentUser.id,
        documentId: note.documentId,
        text: text,
        title: title,
        isPinned: _isPinned,
        isFavourite: _isFavourite,
        createdDate: note.createdDate,
        modifiedDate: Timestamp.now(),
        pinnedDate: _pinnedDate,
        favouriteDate: _favouriteDate,
        category: _selectedNoteCategory,
      );

      _note = CloudNote(
        documentId: documentId,
        ownerUserId: currentUser.id,
        text: _textController.text,
        title: _titleController.text,
        isPinned: _isPinned,
        isFavourite: _isFavourite,
        createdDate: note.createdDate,
        modifiedDate: Timestamp.now(),
        pinnedDate: _pinnedDate,
        favouriteDate: _favouriteDate,
        category: _selectedNoteCategory,
      );

      _wasNoteUpdated = true;
    }
  }

  @override
  void initState() {
    _notesService = FirebaseCloudStorageService();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? newNoteCategory = context.getArgument<String>();
    _selectedNoteCategory = newNoteCategory ?? _selectedNoteCategory;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: () => Navigator.of(context)
              .pop({'note': _note, 'updated': _wasNoteUpdated}),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 17,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _saveNoteIfTextOrTitleNotEmpty,
            icon: const Icon(FontAwesomeIcons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: createOrGetExistingNote(context),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              noteCategories[_note!.category]!['icon']
                                  as IconData,
                            ),
                            const SizedBox(width: 10),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                items: noteCategories.keys
                                    .map(
                                      (category) => DropdownMenuItem<String>(
                                        value: category,
                                        child: Row(
                                          children: [
                                            Text(
                                              '$category Notes',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                                value: _selectedNoteCategory,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedNoteCategory = value as String;
                                  });
                                },
                                isDense: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _titleController,
                          // autofocus: text.isEmpty && title.isEmpty,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                          decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: 'Title',
                              hintStyle: TextStyle(
                                fontSize: 25,
                              )),
                        ),
                        // const SizedBox(height: 5),
                        Text(
                          niceDateFormatter
                              .format(_note!.modifiedDate!.toDate()),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Container(
                                height: 55,
                                width: 4,
                                // margin: const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  color: Color(
                                    noteCategories[_selectedNoteCategory]![
                                        'colorHex'] as int,
                                  ),
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                // autofocus: text.isNotEmpty,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                style: const TextStyle(fontSize: 15),
                                decoration: const InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  hintText: 'Note',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  default:
                    return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
