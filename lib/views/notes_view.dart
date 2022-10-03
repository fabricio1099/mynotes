import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/models/note.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/signout_dialog.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_list_view.dart';
import 'dart:developer' as d show log;

import 'login_view.dart';

class NotesView extends StatefulWidget {
  static const routeName = '/notes';

  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;

  String get userEmail => AuthService.firebase().currentUSer!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    try {
      _notesService.open();
    } on DatabaseAlreadyOpenException {
      d.log('Database already opened');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(CreateUpdateNoteView.routeName);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton(
            itemBuilder: (_) {
              return [
                const PopupMenuItem(
                  child: Text('Sign out'),
                  value: MenuAction.logout,
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldSignout = await showSignOutDialog(context);
                  if (shouldSignout) {
                    try {
                      AuthService.firebase().signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        LoginView.routeName,
                        (route) => false,
                      );
                    } on UserNotLoggedInAuthException {
                      await showErrorDialog(context, "You're not signed in!");
                    } on GenericAuthException {
                      await showErrorDialog(context, 'Failed to sign out');
                    }
                  }
                  break;
                default:
                  d.log('default menu action');
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async {
                            await _notesService.deleteNote(id: note.id);
                          },
                          onTap: (note) {
                            Navigator.of(context).pushNamed(
                              CreateUpdateNoteView.routeName,
                              arguments: note,
                            );
                          },
                        );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    case ConnectionState.done:
                      final notes = (snapshot.data as List<DatabaseNote>)
                          .map((note) => Text(note.text))
                          .toList();
                      return Column(
                        children: notes,
                      );
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
