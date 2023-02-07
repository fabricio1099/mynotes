import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/constants/note_categories.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

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
  final String _noteCategory = noteCategories.keys.firstWhere((key) => key == "Random");
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
      category: _noteCategory,
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
        category: _noteCategory,
      );

      _note = CloudNote(
        documentId: documentId,
        ownerUserId: currentUser.id,
        text: _textController.text,
        title: _titleController.text,
        isPinned: _isPinned,
        isFavourite: _isFavourite,
        createdDate: note.createdDate,
        modifiedDate: note.modifiedDate,
        pinnedDate: _pinnedDate,
        favouriteDate: _favouriteDate,
        category: _noteCategory,
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const BackButtonIcon(),
          onPressed: () => Navigator.of(context).pop({'note': _note, 'updated': _wasNoteUpdated}),
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
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_note == null || text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FutureBuilder(
            future: createOrGetExistingNote(context),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  final text = _textController.text;
                  final title = _titleController.text;
                  // _setupNoteControllerListener();
                  return Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        autofocus: text.isEmpty && title.isEmpty,
                        style: const TextStyle(
                          fontSize: 25,
                        ),
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Title',
                            hintStyle: TextStyle(
                              fontSize: 25,
                            )),
                      ),
                      TextField(
                        controller: _textController,
                        autofocus: text.isNotEmpty,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Note',
                        ),
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
    );
  }
}
