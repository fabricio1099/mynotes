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

  Future<String> saveNote({
    required String ownerUserId,
    required String documentId,
    required String text,
    required String title,
    required bool isPinned,
    required bool isFavourite,
    required Timestamp? createdDate,
    required Timestamp? modifiedDate,
    required Timestamp? pinnedDate,
    required Timestamp? favouriteDate,
    required String category,
  }) async {
    if (documentId == CloudNote.initialNoteDocumentId) {
      try {
        final document = await notes.add({
          ownerUserIdFieldName: ownerUserId,
          textFieldName: text,
          titleFieldName: title,
          ownerUserId: ownerUserId,
          isPinnedFieldName: isPinned,
          isFavouriteFieldName: isFavourite,
          createdDateFieldName: createdDate,
          modifiedDateFieldName: modifiedDate,
          pinnedDateFieldName: pinnedDate,
          favouriteDateFieldName: favouriteDate,
          categoryFieldName: category,
        });
        final fetchedNote = await document.get();
        return fetchedNote.id;
      } catch (e) {
        throw CouldNotCreateNoteException();
      }
    } else {
      try {
        await notes.doc(documentId).update({
          ownerUserIdFieldName: ownerUserId,
          textFieldName: text,
          titleFieldName: title,
          ownerUserId: ownerUserId,
          isPinnedFieldName: isPinned,
          isFavouriteFieldName: isFavourite,
          createdDateFieldName: createdDate,
          modifiedDateFieldName: modifiedDate,
          pinnedDateFieldName: pinnedDate,
          favouriteDateFieldName: favouriteDate,
          categoryFieldName: category,
        });
        return documentId;
      } catch (e) {
        throw CouldNotUpdateNoteException();
      }
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map(
          (event) => event.docs.map(
            (doc) {
              return CloudNote.fromSnapshot(doc);
            },
          ),
        );
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
    required String title,
    required bool isPinned,
    required bool isFavourite,
    required Timestamp? createdDate,
    required Timestamp? modifiedDate,
    required Timestamp? pinnedDate,
    required Timestamp? favouriteDate,
    required String category,
  }) async {
    try {
      await notes.doc(documentId).update({
        textFieldName: text,
        titleFieldName: title,
        createdDateFieldName: createdDate,
        modifiedDateFieldName: modifiedDate,
        isPinnedFieldName: isPinned,
        pinnedDateFieldName: pinnedDate,
        isFavouriteFieldName: isFavourite,
        favouriteDateFieldName: favouriteDate,
        categoryFieldName: category,
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
