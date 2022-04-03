import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as d show log;

import 'login_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          PopupMenuButton(
            itemBuilder: (_) {
              return const [
                PopupMenuItem(
                  child: Text('Sign out'),
                  value: MenuAction.logout,
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldSignout = await showSignOutDialog(context);
                  if(shouldSignout) await FirebaseAuth.instance.signOut();
                  d.log('$shouldSignout');
                  Navigator.of(context).pushNamedAndRemoveUntil(LoginView.routeName, (route) => false);
                  break;
                default:
                  d.log('default menu action');
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          children: const [
            Text('Done'),
          ],
        ),
      ),
    );
  }
}

Future<bool> showSignOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  ).then((value) {
    return value ?? false;
  });
}

enum MenuAction {
  logout,
}
