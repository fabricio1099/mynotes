import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/utilities/widgets/custom_pinned_date_item.dart';

class CustomPinnedNotesCarousel extends StatelessWidget {
  const CustomPinnedNotesCarousel({
    Key? key,
    required this.pinnedNotes,
  }) : super(key: key);

  final List<CloudNote> pinnedNotes;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: pinnedNotes.length,
      itemBuilder: (context, itemIndex, pageViewIndex) {
        final note = pinnedNotes.elementAt(itemIndex);
        return CustomPinnedNoteItem(note: note);
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
    );
  }
}