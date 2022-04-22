import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;
import 'package:mynotes/models/user.dart' hide idColumn;
import 'package:mynotes/models/note.dart' hide idColumn;
import 'package:mynotes/services/crud/crud_exceptions.dart';

const dbName = 'notes.db';

const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user" (
	        "id"	INTEGER NOT NULL,
	        "email"	TEXT NOT NULL UNIQUE,
	        PRIMARY KEY("id" AUTOINCREMENT)
        );
      ''';

const createNoteTable = '''
        CREATE TABLE IF NOT EXISTS "note" (
        	"id"	INTEGER NOT NULL,
        	"user_id"	INTEGER NOT NULL,
        	"title"	TEXT,
        	"text"	TEXT,
        	"is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        	FOREIGN KEY("user_id") REFERENCES "user"("id"),
        	PRIMARY KEY("id")
        );
      ''';

class NotesService {
  Database? _db;

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      User.tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<User> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      User.tableName,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(User.tableName, {
      emailColumn: email.toLowerCase(),
    });

    return User(
      id: userId,
      email: email,
    );
  }

  Future<User> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      User.tableName,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return User.fromDbRow(results.first);
    }
  }

  Future<Note> createNote({required User owner}) async {
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const title = '';
    const text = '';
    const isSyncedWithCloud = true;
    final values = {
      userIdColumn: owner.id,
      titleColumn: title,
      textColumn: text,
      // ignore: dead_code
      isSyncedWithCloudColumn: isSyncedWithCloud ? 1 : 0,
    };

    final noteId = await db.insert(
      Note.tableName,
      values,
    );

    final note = Note(
      id: noteId,
      userId: owner.id,
      title: title,
      text: text,
      isSyncedWithCloud: isSyncedWithCloud,
    );

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      Note.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(Note.tableName);
  }

  Future<Note> getNote(int id) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      Note.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      return Note.fromDbRow(results.first);
    }
  }

  Future<Iterable<Note>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(Note.tableName);

    if (results.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final notes = results.map((noteRow) => Note.fromDbRow(noteRow));
      return notes;
    }
  }

  Future<Note> updateNote({required Note note, required String text, String title = ''}) async {
    final db = _getDatabaseOrThrow();

    await getNote(note.id);

    final values = {
      titleColumn: title,
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    };

    final updatesCount = await db.update(
      Note.tableName,
      values,
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if(updatesCount == 0){
      throw CouldNotUpdateNote();
    }else{
      return await getNote(note.id);
    }
  }
}
