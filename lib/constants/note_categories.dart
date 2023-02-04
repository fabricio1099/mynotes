import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/constants/colors.dart';

const noteCategories = <String, Map<String, Object>>{
  "Work": {
    "colorHex": lightBlueHex,
    "icon": FontAwesomeIcons.briefcase,
  },
  "Random": {
    "colorHex": veryPaleOrangeHex,
    "icon": FontAwesomeIcons.shuffle,
  },
  "Record": {
    "colorHex": veryPaleCyanHex,
    "icon": FontAwesomeIcons.fileWaveform,
  },
  "Design": {
    "colorHex": veryPaleYellowHex,
    "icon": FontAwesomeIcons.paintbrush,
  },
  "Message": {
    "colorHex": veryPaleVioletHex,
    "icon": FontAwesomeIcons.solidMessage,
  },
};