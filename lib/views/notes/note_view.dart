import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/widgets/custom_floating_action_button.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';

class NoteView extends StatefulWidget {
  static const routeName = '/open-note';

  const NoteView({Key? key}) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  CloudNote? _note;
  bool _wasNoteUpdated = false;
  CloudNote? _updatedNote;

  Future<void> getExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    // if (widgetNote != null) {
    _note = widgetNote;
    // return widgetNote;
    // }

    // final currentUser = AuthService.firebase().currentUser!;
    // final newNote = CloudNote(
    //   documentId: CloudNote.initialNoteDocumentId,
    //   ownerUserId: currentUser.id,
    //   text: '',
    //   title: '',
    //   createdDate: Timestamp.now(),
    //   modifiedDate: Timestamp.now(),
    //   category: _noteCategory,
    // );
    // _note = newNote;
    // return newNote;
  }

  void _openUpdateNoteScreen() {
    Navigator.of(context)
        .pushNamed(CreateUpdateNoteView.routeName, arguments: _note)
        .then(
      (value) {
        final updateData = (value as Map<String, Object?>);
        _wasNoteUpdated = updateData['updated'] as bool;
        if (_wasNoteUpdated) {
          _updatedNote = updateData['note'] as CloudNote;
          setState(() {
            _note = _updatedNote;
          });
        }
      },
    );
  }

  // @override
  @override
  Widget build(BuildContext context) {
    if (!_wasNoteUpdated) {
      final widgetNote = context.getArgument<CloudNote>();
      _note = widgetNote;
    }
    return Scaffold(
      floatingActionButton: CustomFloatingActionButton(
        context: context,
        onPressed: _openUpdateNoteScreen,
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 17,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(FontAwesomeIcons.circleQuestion),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child:
              // Builder(
              //   // future: getExistingNote(context),
              //   builder: (context) {
              //         // final text = _textController.text;
              //         // final title = _titleController.text;
              //         // if (_note != null) {
              //           // final note = _note;
              //           return
              Column(
            children: [
              Text(_note!.title),
              Text(_note!.text),
            ],
          ),
          // } else {
          //   return const Center(
          //       child: Text("an error occured : couldn't load note"));
          // }

          //   },
          // ),
        ),
      ),
    );
  }
}
