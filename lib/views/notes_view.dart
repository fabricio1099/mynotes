import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mynotes/models/note.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/widgets/custom_floating_action_button.dart';
import 'package:mynotes/utilities/widgets/custom_note_item.dart';
import 'package:mynotes/utilities/widgets/custom_note_view_app_bar.dart';
import 'package:mynotes/utilities/widgets/custom_pinned_notes_carousel.dart';
import 'package:mynotes/utilities/widgets/custom_tab_bar.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:group_list_view/group_list_view.dart';

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

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

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

  void openNewNoteScreen() {
    Navigator.of(context).pushNamed(CreateUpdateNoteView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: CustomFloatingActionButton(
          context: context,
          onPressed: openNewNoteScreen,
        ),
        appBar: CustomNoteViewAppBar(context: context),
        body: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allNotes = snapshot.data as Iterable<CloudNote>;

                  SplayTreeMap<String, List<CloudNote>>
                      allNotesMappedByModifiedDate =
                      SplayTreeMap<String, List<CloudNote>>();
                  allNotesMappedByModifiedDate = _buildNotesModifiedByDateMap(
                    allNotes,
                    allNotesMappedByModifiedDate,
                  );

                  allNotesMappedByModifiedDate = _sortNotesByModifiedDateDesc(
                    allNotesMappedByModifiedDate,
                  );

                  final pinnedNotes =
                      allNotes.where((note) => note.isPinned).toList();

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
                        if (pinnedNotes.isNotEmpty)
                          CustomPinnedNotesCarousel(pinnedNotes: pinnedNotes),
                        if (pinnedNotes.isNotEmpty)
                          const SizedBox(
                            height: 20,
                          ),
                        CustomTabBar(tabController: _tabController),
                        const SizedBox(height: 20),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // TODO: extract to CustomNotesListView widget
                              GroupListView(
                                itemBuilder: (context, index) {
                                  List<CloudNote> sortedValues =
                                      allNotesMappedByModifiedDate.values
                                          .toList()[index.section];
                                  sortedValues.sort((note1, note2) {
                                    return note2.modifiedDate!
                                        .compareTo(note1.modifiedDate!);
                                  });
                                  final note = sortedValues[index.index];
                                  return CustomNoteItem(note: note);
                                },
                                sectionsCount: allNotesMappedByModifiedDate.keys
                                    .toList()
                                    .length,
                                groupHeaderBuilder: ((context, section) {
                                  String dateToDisplay = _formatDateToDisplay(
                                    allNotesMappedByModifiedDate,
                                    section,
                                  );

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      dateToDisplay,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }),
                                countOfItemInSection: (section) {
                                  return allNotesMappedByModifiedDate.values
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
          },
        ),
      ),
    );
  }

  String _formatDateToDisplay(
      SplayTreeMap<String, List<CloudNote>> allNotesMappedByModifiedDate,
      int section) {
    String dateToDisplay = allNotesMappedByModifiedDate.keys.toList()[section];

    DateTime dateToCheck = _dateFormatter.parse(dateToDisplay);

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(
      now.year,
      now.month,
      now.day,
    );
    final DateTime yesterday = DateTime(
      now.year,
      now.month,
      now.day - 1,
    );

    if (dateToCheck == today) {
      dateToDisplay = 'Today';
    }
    if (dateToCheck == yesterday) {
      dateToDisplay = 'Yesterday';
    }
    return dateToDisplay;
  }

  SplayTreeMap<String, List<CloudNote>> _sortNotesByModifiedDateDesc(
    SplayTreeMap<String, List<CloudNote>> allNotesMappedByModifiedDate,
  ) {
    allNotesMappedByModifiedDate = SplayTreeMap.from(
      allNotesMappedByModifiedDate,
      (key1, key2) {
        final date1 = _dateFormatter.parse(key1);
        final date2 = _dateFormatter.parse(key2);
        return date2.compareTo(date1);
      },
    );
    return allNotesMappedByModifiedDate;
  }

  SplayTreeMap<String, List<CloudNote>> _buildNotesModifiedByDateMap(
    Iterable<CloudNote> allNotes,
    SplayTreeMap<String, List<CloudNote>> allNotesMappedByModifiedDate,
  ) {
    for (var note in allNotes.toList()) {
      final String modifiedDateFormatted =
          _dateFormatter.format(note.modifiedDate!.toDate());
      if (!allNotesMappedByModifiedDate.containsKey(modifiedDateFormatted)) {
        allNotesMappedByModifiedDate[modifiedDateFormatted] = [note];
      } else {
        allNotesMappedByModifiedDate[modifiedDateFormatted]!.add(note);
      }
    }
    return allNotesMappedByModifiedDate;
  }
}
