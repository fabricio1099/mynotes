import 'package:flutter/material.dart';

class NewNotesView extends StatefulWidget {
  static const routeName = '/new-note';

  const NewNotesView({Key? key}) : super(key: key);

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New note'),
      ),
      body: const Text('Write you new note here'),
    );
  }
}
