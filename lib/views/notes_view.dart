import 'dart:collection';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mynotes/constants/colors.dart';
import 'package:mynotes/models/note.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/widgets/rounded_rectangle_tabbar_indicator.dart';
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

                    SplayTreeMap<String, List<CloudNote>>
                        allNotesMappedByModifiedDate =
                        SplayTreeMap<String, List<CloudNote>>();
                    for (var note in allNotes.toList()) {
                      final String modifiedDateFormatted =
                          formatter.format(note.modifiedDate!.toDate());
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
                    allNotesMappedByModifiedDate = SplayTreeMap.from(
                      allNotesMappedByModifiedDate,
                      (key1, key2) {
                        final date1 = formatter.parse(key1);
                        final date2 = formatter.parse(key2);
                        return date2.compareTo(date1);
                      },
                    );

                    final allNotesSortedByModifiedDate = allNotes.toList();
                    allNotesSortedByModifiedDate.sort(
                      (note1, note2) {
                        return note1.modifiedDate!
                            .compareTo(note2.modifiedDate!);
                      },
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
                            CarouselSlider.builder(
                              itemCount: pinnedNotes.length,
                              itemBuilder: (context, itemIndex, pageViewIndex) {
                                final note = pinnedNotes.elementAt(itemIndex);
                                return Container(
                                  decoration: BoxDecoration(
                                    color: veryPaleBlue,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        title: Text(
                                          note.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                              size: 14,
                                            ),
                                            SizedBox(width: 5),
                                            Text('Pinned'),
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
                            indicator: RRectTabIndicator(
                              color: lightBlue,
                              radius: 3,
                              rectangleWidth: 40,
                              rectangleHeight: 3,
                              verticalOffset: 8,
                            ),
                            tabs: const [
                              Tab(
                                child: Text(
                                  'Recent',
                                  style: TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Favourites',
                                  style: TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'Shared With Me',
                                  style: TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                            ],
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
                                    return GestureDetector(
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
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            stops: [0.02, 0.02],
                                            colors: [Colors.red, Colors.white],
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
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
                                    );
                                  },
                                  sectionsCount: allNotesMappedByModifiedDate
                                      .keys
                                      .toList()
                                      .length,
                                  groupHeaderBuilder: ((context, section) {
                                    String date = allNotesMappedByModifiedDate
                                        .keys
                                        .toList()[section];

                                    DateTime dateToCheck =
                                        formatter.parse(date);
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
            }),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
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
            const SizedBox(width: 15),
            GestureDetector(
              onTap: (() {
                Navigator.of(context).pushNamed(ProfileView.routeName);
              }),
              child: CircleAvatar(
                radius: 20,
                backgroundImage: Image.asset('assets/icon/avatar-80.png').image,
                backgroundColor: veryPaleBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
