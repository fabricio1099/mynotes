import 'dart:collection';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mynotes/constants/colors.dart';
import 'package:mynotes/constants/home_page_tabs.dart';
import 'package:mynotes/constants/note_categories.dart';
import 'package:mynotes/models/note.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/widgets/custom_floating_action_button.dart';
import 'package:mynotes/utilities/widgets/custom_tabbar_indicator.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:group_list_view/group_list_view.dart';
import 'package:mynotes/views/notes/profile_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
                  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

                  SplayTreeMap<String, List<CloudNote>>
                      allNotesMappedByModifiedDate =
                      SplayTreeMap<String, List<CloudNote>>();

                  //build notes map by modified date
                  for (var note in allNotes.toList()) {
                    final String modifiedDateFormatted =
                        dateFormatter.format(note.modifiedDate!.toDate());
                    if (!allNotesMappedByModifiedDate
                        .containsKey(modifiedDateFormatted)) {
                      allNotesMappedByModifiedDate[modifiedDateFormatted] = [
                        note
                      ];
                    } else {
                      allNotesMappedByModifiedDate[modifiedDateFormatted]!
                          .add(note);
                    }
                  }

                  //sort mapped notes by modified date desc
                  allNotesMappedByModifiedDate = SplayTreeMap.from(
                    allNotesMappedByModifiedDate,
                    (key1, key2) {
                      final date1 = dateFormatter.parse(key1);
                      final date2 = dateFormatter.parse(key2);
                      return date2.compareTo(date1);
                    },
                  );

                  // final allNotesSortedByModifiedDate = allNotes.toList();
                  // allNotesSortedByModifiedDate.sort(
                  //   (note1, note2) {
                  //     return note1.modifiedDate!.compareTo(note2.modifiedDate!);
                  //   },
                  // );

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
                          CarouselSlider.builder(
                            itemCount: pinnedNotes.length,
                            itemBuilder: (context, itemIndex, pageViewIndex) {
                              final note = pinnedNotes.elementAt(itemIndex);
                              return Container( //TODO: extract to CustomPinnedDate widget
                                decoration: BoxDecoration(
                                  color: const Color(veryPaleBlueHex),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        child: Text(
                                          note.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      subtitle: Text(
                                        note.text,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      isThreeLine: true,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: const [
                                          Icon(
                                            FontAwesomeIcons.mapPin,
                                            color: Color(lightBlueHex),
                                            size: 14,
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            'Pinned',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
                        if (pinnedNotes.isNotEmpty)
                          const SizedBox(
                            height: 20,
                          ),
                        TabBar(
                          labelPadding:
                              const EdgeInsets.only(left: 0, right: 20),
                          indicatorPadding:
                              const EdgeInsets.only(left: 0, right: 20),
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.grey,
                          indicator: CustomTabIndicator(
                            color: const Color(lightBlueHex),
                            radius: 3,
                            rectangleWidth: 40,
                            rectangleHeight: 3,
                            verticalOffset: 8,
                          ),
                          tabs: homePageTabs,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
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
                                  return GestureDetector( //TODO: extract to CustomNoteItem widget
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        CreateUpdateNoteView.routeName,
                                        arguments: note,
                                      );
                                    },
                                    child: Container(
                                      height: 80,
                                      margin: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      padding: const EdgeInsets.only(
                                        top: 5,
                                        bottom: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          stops: const [0.02, 0.02],
                                          colors: [
                                            Color(
                                              noteCategories[note.category]![
                                                  'colorHex'] as int,
                                            ),
                                            Colors.white,
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ListTile(
                                              title: Text(
                                                note.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                note.text,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 25,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 30,
                                            ),
                                            child: Chip(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(8),
                                                ),
                                              ),
                                              backgroundColor: Color(
                                                  noteCategories[
                                                          note.category]![
                                                      'colorHex'] as int),
                                              label: Text(note.category),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                sectionsCount: allNotesMappedByModifiedDate.keys
                                    .toList()
                                    .length,
                                groupHeaderBuilder: ((context, section) {
                                  //TODO: reactor date formating
                                  String date = allNotesMappedByModifiedDate
                                      .keys
                                      .toList()[section];

                                  DateTime dateToCheck =
                                      dateFormatter.parse(date);
                                  dateToCheck = DateTime(
                                    dateToCheck.year,
                                    dateToCheck.month,
                                    dateToCheck.day,
                                  );

                                  final now = DateTime.now();
                                  final today = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                  );
                                  final yesterday = DateTime(
                                    now.year,
                                    now.month,
                                    now.day - 1,
                                  );

                                  if (dateToCheck == today) {
                                    date = 'Today';
                                  }

                                  if (dateToCheck == yesterday) {
                                    date = 'Yesterday';
                                  }

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
}
