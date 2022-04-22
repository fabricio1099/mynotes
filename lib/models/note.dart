import 'package:flutter/foundation.dart';

const idColumn = 'id';
const userIdColumn = 'user_id';
const titleColumn = 'title';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';

@immutable
class Note {
  static const tableName = 'note';

  final int id;
  final int userId;
  final String title;
  final String text;
  final bool isSyncedWithCloud;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.text,
    required this.isSyncedWithCloud,
  });

  //representation type of a Row in database -> Map<String, Object?>
  Note.fromDbRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, title = $title, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant Note other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}
