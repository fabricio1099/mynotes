import 'dart:collection';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mynotes/constants/app_bar_constants.dart';
import 'package:mynotes/constants/colors.dart';
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
import 'package:group_list_view/group_list_view.dart';
import 'package:mynotes/views/notes/profile_view.dart';

extension Count<T extends Iterable> on Stream<T> {
  Stream<int> get getLength => map((event) => event.length);
}

class NotesView extends StatefulWidget {
  static const routeName = '/notes';

  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> with TickerProviderStateMixin {
  late final FirebaseCloudStorageService _notesService;

  String get userId => AuthService.firebase().currentUser!.id;

  late final TabController _tabController;

  @override
  void initState() {
    _notesService = FirebaseCloudStorageService();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
    );
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: SizedBox(
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pushNamed(CreateUpdateNoteView.routeName);
            },
            child: const Icon(
              Icons.edit,
            ),
            mini: false,
            tooltip: 'Add a new note',
          ),
        ),
        appBar: buildAppBar(),
        body: StreamBuilder(
            stream: _notesService.allNotes(ownerUserId: userId),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.active:
                  if (snapshot.hasData) {
                    final allNotes = snapshot.data as Iterable<CloudNote>;
                    final DateFormat formatter = DateFormat('dd/MM/yyyy');

                    SplayTreeMap<String, List<CloudNote>> mappedNotes =
                        SplayTreeMap<String, List<CloudNote>>();
                    for (var note in allNotes.toList()) {
                      final String modifiedDateFormatted =
                          formatter.format(note.modifiedDate!.toDate());
                      if (!mappedNotes.containsKey(modifiedDateFormatted)) {
                        mappedNotes[modifiedDateFormatted] = [note];
                      } else {
                        mappedNotes[modifiedDateFormatted]!.add(note);
                      }
                    }
                    mappedNotes = SplayTreeMap.from(
                      mappedNotes,
                      (key1, key2) {
                        final date1 = DateFormat('dd/MM/yyyy').parse(key1);
                        final date2 = DateFormat('dd/MM/yyyy').parse(key2);
                        return date2.compareTo(date1);
                      },
                    );

                    final sortedNotes = allNotes.toList();
                    sortedNotes.sort(
                      (note1, note2) {
                        return note1.modifiedDate!
                            .compareTo(note2.modifiedDate!);
                      },
                    );
                    return Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Notes',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CarouselSlider.builder(
                            itemCount: sortedNotes.length,
                            itemBuilder: (context, itemIndex, pageViewIndex) {
                              final note = sortedNotes.elementAt(itemIndex);
                              return Container(
                                decoration: BoxDecoration(
                                  color: myColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(note.text),
                              );
                            },
                            options: CarouselOptions(
                              autoPlay: false,
                              enableInfiniteScroll: false,
                              scrollDirection: Axis.horizontal,
                              viewportFraction: 0.5,
                              disableCenter: true,
                              enlargeCenterPage: true,
                              initialPage: 0,
                              aspectRatio: 27 / 9,
                              pageSnapping: true,
                              padEnds: false,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelPadding:
                                const EdgeInsets.only(left: 0, right: 20),
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicator: const UnderlineTabIndicator(
                              borderSide:
                                  BorderSide(width: 5.0, color: Colors.blue),
                              insets: EdgeInsets.symmetric(horizontal: 16.0),
                            ),
                            tabs: const [
                              Tab(
                                child: Text(
                                  'Recent',
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Favourites',
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Shared With Me',
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                GroupListView(
                                  itemBuilder: (context, index) {
                                    List<CloudNote> sortedValues = mappedNotes
                                        .values
                                        .toList()[index.section];
                                    sortedValues.sort((note1, note2) {
                                      return note2.modifiedDate!
                                          .compareTo(note1.modifiedDate!);
                                    });
                                    final note = sortedValues[index.index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          CreateUpdateNoteView.routeName,
                                          arguments: note,
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 10, bottom: 10),
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            stops: [0.02, 0.02],
                                            colors: [Colors.red, Colors.white],
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        child: ListTile(
                                          title: Text(note.title),
                                          subtitle: Text(note.text),
                                        ),
                                      ),
                                    );
                                  },
                                  sectionsCount:
                                      mappedNotes.keys.toList().length,
                                  groupHeaderBuilder: ((context, section) {
                                    String date =
                                        mappedNotes.keys.toList()[section];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Text(
                                        date,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }),
                                  countOfItemInSection: (section) {
                                    return mappedNotes.values
                                        .toList()[section]
                                        .length;
                                  },
                                ),
                                const Text('tabview2'),
                                const Text('tabview3'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
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
            }),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: SizedBox(
                height: 35,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  maxLines: 1,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    prefixIcon: Icon(
                      Icons.search,
                    ),
                    hintText: 'Search notes',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFE0C8FF),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              width: 60,
              child: GestureDetector(
                onTap: (() {
                  Navigator.of(context).pushNamed(ProfileView.routeName);
                }),
                child: const CircleAvatar(
                  child: Image(
                    image: AssetImage(('assets/icon/icon.png')),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Scaffold(
  //       floatingActionButton: SizedBox(
  //         width: kAppBarHeight,
  //         height: kAppBarHeight,
  //         child: FloatingActionButton(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //             side: const BorderSide(
  //               color: Colors.white,
  //               width: 0.1,
  //             ),
  //           ),
  //           onPressed: () {
  //             Navigator.of(context).pushNamed(CreateUpdateNoteView.routeName);
  //           },
  //           backgroundColor: Colors.redAccent.shade100,
  //           child: const Icon(
  //             Icons.add,
  //             color: Colors.black38,
  //             size: 40,
  //           ),
  //           mini: false,
  //           tooltip: 'Add a new note',
  //         ),
  //       ),
  //       appBar: PreferredSize(
  //         preferredSize: Size.fromHeight(kAppBarHeight),
  //         child: Container(
  //           padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
  //           child: AppBar(
  //             iconTheme: const IconThemeData(
  //               color: Colors.black,
  //               size: 17,
  //             ),
  //             titleTextStyle: const TextStyle(
  //               color: Colors.black,
  //               fontSize: 15,
  //             ),
  //             backgroundColor: Colors.lightBlue.shade100,
  //             toolbarHeight: kAppBarHeight,
  //             scrolledUnderElevation: 3,
  //             shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(Radius.circular(12)),
  //               side: BorderSide(
  //                 width: 0,
  //                 color: Colors.transparent,
  //               ),
  //             ),
  //             elevation: 0,
  //             title: StreamBuilder<int>(
  //               stream: _notesService.allNotes(ownerUserId: userId).getLength,
  //               builder: (context, snapshot) {
  //                 if (snapshot.hasData) {
  //                   final noteCount = snapshot.data ?? 0;
  //                   final text = context.loc.notes_title(noteCount);
  //                   return Text(
  //                     text,
  //                   );
  //                 } else {
  //                   return const Text('');
  //                 }
  //               },
  //             ),
  //             actions: [
  //               PopupMenuButton(
  //                 itemBuilder: (_) {
  //                   return [
  //                     const PopupMenuItem(
  //                       child: Text('Log Out'),
  //                       value: MenuAction.logout,
  //                     ),
  //                   ];
  //                 },
  //                 onSelected: (value) async {
  //                   switch (value) {
  //                     case MenuAction.logout:
  //                       final shouldLogout = await showLogOutDialog(context);
  //                       if (shouldLogout) {
  //                         try {
  //                           context.read<AuthBloc>().add(
  //                                 const AuthEventLogOut(),
  //                               );
  //                         } on UserNotLoggedInAuthException {
  //                           await showErrorDialog(
  //                               context, "You're not logged in!");
  //                         } on GenericAuthException {
  //                           await showErrorDialog(context, 'Failed to log out');
  //                         }
  //                       }
  //                       break;
  //                     default:
  //                       d.log('default menu action');
  //                   }
  //                 },
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //       body: StreamBuilder(
  //         stream: _notesService.allNotes(ownerUserId: userId),
  //         builder: (context, snapshot) {
  //           switch (snapshot.connectionState) {
  //             case ConnectionState.waiting:
  //             case ConnectionState.active:
  //               if (snapshot.hasData) {
  //                 final allNotes = snapshot.data as Iterable<CloudNote>;
  //                 return NotesGridView(
  //                   notes: allNotes,
  //                   onDeleteNote: (note) async {
  //                     await _notesService.deleteNote(
  //                         documentId: note.documentId);
  //                   },
  //                   onTap: (note) {
  //                     Navigator.of(context).pushNamed(
  //                       CreateUpdateNoteView.routeName,
  //                       arguments: note,
  //                     );
  //                   },
  //                 );
  //               } else {
  //                 return const CircularProgressIndicator();
  //               }
  //             case ConnectionState.done:
  //               final notes = (snapshot.data as List<DatabaseNote>)
  //                   .map((note) => Text(note.text))
  //                   .toList();
  //               return Column(
  //                 children: notes,
  //               );
  //             default:
  //               return const CircularProgressIndicator();
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }
}
