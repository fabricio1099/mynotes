import 'dart:async';
import 'package:mynotes/extensions/list/filter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;
import 'package:mynotes/models/user.dart' hide idColumn;
import 'package:mynotes/models/note.dart' hide idColumn;
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'dart:developer' as d show log;

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  DatabaseUser? _currentUser;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  late final StreamController<List<DatabaseNote>> _notesStreamController;

  Stream<List<DatabaseNote>> get allNotes {
    return _notesStreamController.stream.filter(
      (note) {
        final currentUser = _currentUser;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      },
    );
  }

  Future<void> _cacheNotes() async {
    try {
      final allNotes = await getAllNotes();
      _notes = allNotes.toList();
      _notesStreamController.add(_notes);
    } catch (e) {
      d.log('could not find any notes');
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create user table
      await db.execute(createUserTable);
      // create note table
      await db.execute(createNoteTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectoryException();
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
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

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _currentUser = user;
      }
      return user;
    } on CouldNotFindUserException {
      final createdUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _currentUser = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      DatabaseUser.tableName,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      DatabaseUser.tableName,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExistsException();
    }

    final userId = await db.insert(DatabaseUser.tableName, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      DatabaseUser.tableName,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromDbRow(results.first);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
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
      DatabaseNote.tableName,
      values,
    );

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      title: title,
      text: text,
      isSyncedWithCloud: isSyncedWithCloud,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      DatabaseNote.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(DatabaseNote.tableName);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<DatabaseNote> getNote(int id) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      DatabaseNote.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNote.fromDbRow(results.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(DatabaseNote.tableName);

    if (results.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final notes = results.map((noteRow) => DatabaseNote.fromDbRow(noteRow));
      return notes;
    }
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note,
      required String text,
      String title = ''}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure note exists
    await getNote(note.id);

    final values = {
      titleColumn: title,
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    };

    //update note in db
    final updatesCount = await db.update(
      DatabaseNote.tableName,
      values,
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }
}

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
