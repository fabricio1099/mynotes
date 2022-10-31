import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/app_bar_constants.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/models/note.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes/notes_grid_view.dart';
import 'dart:developer' as d show log;

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class NotesView extends StatefulWidget {
  static const routeName = '/notes';

  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorageService _notesService;

  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorageService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: SizedBox(
          width: kAppBarHeight,
          height: kAppBarHeight,
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: Colors.white,
                width: 0.1,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(CreateUpdateNoteView.routeName);
            },
            backgroundColor: Colors.redAccent.shade100,
            child: const Icon(
              Icons.add,
              color: Colors.black38,
              size: 40,
            ),
            mini: false,
            tooltip: 'Add a new note',
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kAppBarHeight),
          child: Container(
            padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
            child: AppBar(
              iconTheme: const IconThemeData(
                color: Colors.black,
                size: 17,
              ),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 15,
              ),
              backgroundColor: Colors.lightBlue.shade100,
              toolbarHeight: kAppBarHeight,
              scrolledUnderElevation: 3,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                side: BorderSide(
                  width: 0,
                  color: Colors.transparent,
                ),
              ),
              elevation: 0,
              title: StreamBuilder<int>(
                stream: _notesService.allNotes(ownerUserId: userId).getLength,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final noteCount = snapshot.data ?? 0;
                    final text = context.loc.notes_title(noteCount);
                    return Text(
                      text,
                    );
                  } else {
                    return const Text('');
                  }
                },
              ),
              actions: [
                PopupMenuButton(
                  itemBuilder: (_) {
                    return [
                      const PopupMenuItem(
                        child: Text('Log Out'),
                        value: MenuAction.logout,
                      ),
                    ];
                  },
                  onSelected: (value) async {
                    switch (value) {
                      case MenuAction.logout:
                        final shouldLogout = await showLogOutDialog(context);
                        if (shouldLogout) {
                          try {
                            context.read<AuthBloc>().add(
                                  const AuthEventLogOut(),
                                );
                          } on UserNotLoggedInAuthException {
                            await showErrorDialog(
                                context, "You're not logged in!");
                          } on GenericAuthException {
                            await showErrorDialog(context, 'Failed to log out');
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
          ),
        ),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  return NotesGridView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(
                          documentId: note.documentId);
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
        ),
      ),
    );
  }
}
