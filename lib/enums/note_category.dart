import 'package:mynotes/constants/colors.dart';

enum NoteCategory {
  work(lightBlueHex),
  random(veryPaleOrangeHex),
  record(veryPaleCyanHex),
  design(veryPaleYellowHex),
  message(veryPaleVioletHex);

  const NoteCategory(this.colorHex);
  final int colorHex;

  String get print {
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }
}