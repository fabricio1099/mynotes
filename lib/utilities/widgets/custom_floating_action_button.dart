import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/constants/colors.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({
    Key? key,
    required this.context,
    required this.onPressed,
  }) : super(key: key);

  final BuildContext context;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0, right: 8),
      child: FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(
          FontAwesomeIcons.penToSquare,
          size: 18,
        ),
        backgroundColor: const Color(lightBlueHex),
        mini: false,
        tooltip: 'Add a new note',
      ),
    );
  }
}