import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/constants/colors.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/views/notes/note_view.dart';

class CustomPinnedNoteItem extends StatelessWidget {
  const CustomPinnedNoteItem({
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
        decoration: BoxDecoration(
          color: const Color(veryPaleBlueHex),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Padding(
                padding:
                    const EdgeInsets.only(bottom: 5),
                child: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: Text(
                note.text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: const [
                  Icon(
                    FontAwesomeIcons.mapPin,
                    color: Color(lightBlueHex),
                    size: 14,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'Pinned',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}