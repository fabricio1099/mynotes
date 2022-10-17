import 'package:flutter/material.dart';
import 'package:mynotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Sign out',
    content: 'Are you sure you want to sign out ?',
    optionBuilder: () => {
      'Cancel': false,
      'Sign out': true,
    },
  ).then((value) => value ?? false);
}
