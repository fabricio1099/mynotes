import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

class CloudNote {
  static const String collectionName = 'notes';
  static const String initialNoteDocumentId = '000000';

  final String documentId;
  final String ownerUserId;
  final String text;
  final String title;
  final bool isPinned;
  final bool isFavourite;
  Timestamp? createdDate;
  Timestamp? modifiedDate;
  Timestamp? pinnedDate;
  Timestamp? favouriteDate;
  final String category;

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.title,
    required this.createdDate,
    required this.modifiedDate,
    required this.category,
    this.isPinned = false,
    this.isFavourite = false,
    this.pinnedDate,
    this.favouriteDate,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String,
        title = snapshot.data()[titleFieldName] as String,
        isPinned = snapshot.data()[isPinnedFieldName] as bool,
        isFavourite = snapshot.data()[isFavouriteFieldName] as bool,
        category = snapshot.data()[categoryFieldName] as String {
    createdDate = snapshot.data()[createdDateFieldName];
    modifiedDate = snapshot.data()[modifiedDateFieldName];
    pinnedDate = snapshot.data()[pinnedDateFieldName];
    favouriteDate = snapshot.data()[favouriteDateFieldName];
  }
}
