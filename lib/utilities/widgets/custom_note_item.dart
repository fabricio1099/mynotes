import 'package:flutter/material.dart';
import 'package:mynotes/constants/note_categories.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/note_view.dart';

class CustomNoteItem extends StatelessWidget {
  const CustomNoteItem({
    Key? key,
    required this.note,
  }) : super(key: key);

  final CloudNote note;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          NoteView.routeName,
          arguments: note,
        );
      },
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(
          top: 10,
          bottom: 10,
        ),
        padding: const EdgeInsets.only(
          top: 5,
          bottom: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: const [0.02, 0.02],
            colors: [
              Color(
                noteCategories[note.category]![
                    'colorHex'] as int,
              ),
              Colors.white,
            ],
          ),
          borderRadius: const BorderRadius.all(
              Radius.circular(8)),
        ),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListTile(
                title: Text(
                  note.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  note.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 30,
              ),
              child: Chip(
                shape:
                    const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                backgroundColor: Color(
                    noteCategories[
                            note.category]![
                        'colorHex'] as int),
                label: Text(note.category),
              ),
            ),
          ],
        ),
      ),
    );
  }
}