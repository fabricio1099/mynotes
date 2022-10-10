import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/cloud_storage_constants.dart';
import 'package:mynotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorageService {
  final notes = FirebaseFirestore.instance.collection(CloudNote.collectionName);

  // create a singleton in Dartlang
  static final FirebaseCloudStorageService _shared =
      FirebaseCloudStorageService._sharedInstance();
  FirebaseCloudStorageService._sharedInstance();
  factory FirebaseCloudStorageService() => _shared;

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document = await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: '',
      titleFieldName: '',
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerUserId: ownerUserId,
      text: '',
      title: '',
    );
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) => CloudNote.fromSnapshot(doc),
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes.snapshots().map(
          (event) => event.docs
              .map((doc) => CloudNote.fromSnapshot(doc))
              .where((note) => note.ownerUserId == ownerUserId),
        );
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
    required String title,
  }) async {
    try {
      await notes.doc(documentId).update({
        textFieldName: text,
        titleFieldName: title,
      });
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }
}
