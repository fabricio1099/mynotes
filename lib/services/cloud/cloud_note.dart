import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

class CloudNote {
  static String collectionName = 'notes';

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

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.title,
    required this.createdDate,
    required this.modifiedDate,
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
        isFavourite = snapshot.data()[isFavouriteFieldName] as bool {
    // print('xyz ${snapshot.data()}');
    createdDate = snapshot.data()[createdDateFieldName];
    modifiedDate = snapshot.data()[modifiedDateFieldName];
    pinnedDate = snapshot.data()[pinnedDateFieldName];
    favouriteDate = snapshot.data()[favouriteDateFieldName];

    // this.createdDate = createdDate != null ? createdDate as Timestamp : null;

    // this.createdDate = snapshot.data()[createdDateFieldName] as Timestamp;
    // this.modifiedDate = snapshot.data()[modifiedDateFieldName] as Timestamp;
    // this.pinnedDate = snapshot.data()[pinnedDateFieldName] as Timestamp;
    // this.favouriteDate = snapshot.data()[favouriteDateFieldName] as Timestamp;

    // print('1#### ${createdDate.toString()}');
    // print('2#### ${createdDate.toDate()}');
    // print('3#### $pinnedDate');
    // print('4#### $favouriteDate');
  }
}
