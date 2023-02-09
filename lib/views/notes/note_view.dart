import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/constants/date_formatter.dart';
import 'package:mynotes/constants/note_categories.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/widgets/custom_floating_action_button.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';

class NoteView extends StatefulWidget {
  static const routeName = '/view-note';

  const NoteView({Key? key}) : super(key: key);

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  CloudNote? _note;
  bool _wasNoteUpdated = false;
  CloudNote? _updatedNote;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

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

  @override
  Widget build(BuildContext context) {
    if (!_wasNoteUpdated) {
      _note = context.getArgument<CloudNote>();
    }
    return Scaffold(
      key: _scaffoldkey,
      floatingActionButton: CustomFloatingActionButton(
        context: context,
        onPressed: _openUpdateNoteScreen,
      ),
      appBar: AppBar(
        leadingWidth: 40,
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey.shade200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                _scaffoldkey.currentState?.showBottomSheet((context) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: constraints.maxHeight/3,
                        child: Column(
                          children: const [
                            Text('TODO later'),
                            Text('TEST'),
                            Text('TEST'),
                            Text('TEST'),
                            Text('TEST'),
                            Text('TEST'),
                            Text('TEST'),
                          ],
                        ),
                      );
                    }
                  );
                });
              },
              icon: const Icon(FontAwesomeIcons.fileImport),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                FontAwesomeIcons.microphone,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(FontAwesomeIcons.shareNodes),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(noteCategories[_note!.category]!['icon'] as IconData),
                    const SizedBox(width: 10),
                    Text(
                      '${_note!.category} Notes',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _note!.title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  niceDateFormatter.format(_note!.modifiedDate!.toDate()),
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
                            noteCategories[_note!.category]!['colorHex'] as int,
                          ),
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: Text(_note!.text)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
