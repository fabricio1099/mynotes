import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';

class CloudNote {
  static String collectionName = 'notes';

  final String documentId;
  final String ownerUserId;
  final String text;
  final String title;

  const CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
    required this.title,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot) :
  documentId = snapshot.id,
  ownerUserId = snapshot.data()[ownerUserIdFieldName],
  text = snapshot.data()[textFieldName] as String,
  title = snapshot.data()[titleFieldName] as String;
}
