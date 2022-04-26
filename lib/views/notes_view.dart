import 'package:flutter/material.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/models/note.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'package:mynotes/views/notes/new_notes_view.dart';
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
    _notesService.open();
    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(NewNotesView.routeName);
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
                    } on UserNotLoggedInAuthException {
                      await showErrorDialog(context, "You're not signed in!");
                    } on GenericAuthException {
                      await showErrorDialog(context, 'Failed to sign out');
                    }
                  }
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      LoginView.routeName, (route) => false);
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
        builder: (context, snappshot) {
          switch (snappshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text('Waiting for all notes');
                    case ConnectionState.done:
                      final notes = (snapshot.data as List<Note>)
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

Future<bool> showSignOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  ).then((value) {
    return value ?? false;
  });
}
