import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NotesGridView extends StatefulWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesGridView(
      {Key? key,
      required this.notes,
      required this.onDeleteNote,
      required this.onTap})
      : super(key: key);

  @override
  State<NotesGridView> createState() => _NotesGridViewState();
}

class _NotesGridViewState extends State<NotesGridView> {
  CloudNote? deletedNote;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      padding: const EdgeInsets.only(top: 2, right: 6, left: 6),
      addSemanticIndexes: false,
      itemCount: widget.notes.length,
      crossAxisCount: 2,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      itemBuilder: (context, index) {
        final note = widget.notes.elementAt(index);
        return GestureDetector(
          onTap: () => widget.onTap(note),
          child: Dismissible(
            key: ObjectKey(note),
            onDismissed: (direction) async {
              // deleteItem(index, item);
              deletedNote = note;
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                widget.onDeleteNote(note);
                deletedNote = null;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: Duration(seconds: 5),
                    content: Text(
                      'Note deleted!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                setState(() {});
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border:
                    Border.all(color: Colors.lightBlue.shade300, width: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.title.isNotEmpty)
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (note.title.isNotEmpty) const SizedBox(height: 10),
                    Text(
                      note.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // return ListView.builder(
    //   itemCount: notes.length,
    //   itemBuilder: (context, index) {
    //     final note = notes.elementAt(index);
    //     return ListTile(
    //       title: Text(
    //         note.text,
    //         maxLines: 1,
    //         softWrap: true,
    //         overflow: TextOverflow.ellipsis,
    //       ),
    //       trailing: IconButton(
    //         onPressed: () async {
    //           final shouldDelete = await showDeleteDialog(context);
    //           if (shouldDelete) {
    //             onDeleteNote(note);
    //           }
    //         },
    //         icon: const Icon(Icons.delete),
    //       ),
    //       onTap: () {
    //         onTap(note);
    //       },
    //     );
    //   },
    // );
  }
}

Widget stackBehindDismiss() {
  return Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20.0),
    color: Colors.red,
    child: const Icon(
      Icons.delete,
      color: Colors.white,
    ),
  );
}
