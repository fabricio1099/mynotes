import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/views/categories_view.dart';
import 'package:mynotes/views/notes_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

int _selectedViewIndex = 0;

static const List<Widget> _pages = <Widget>[
    NotesView(),
    Categories(),
    Text('record'),
    Text('settings'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedViewIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedViewIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedViewIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.house,
                color: Colors.grey,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.noteSticky,
                color: Colors.grey,
              ),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.microphone,
                color: Colors.grey,
              ),
              label: 'Record',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                FontAwesomeIcons.gear,
                color: Colors.grey,
              ),
              label: 'Settings',
            ),
          ],
        ),
    );
  }
}