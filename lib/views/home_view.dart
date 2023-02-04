import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mynotes/constants/colors.dart';
import 'package:mynotes/views/categories_view.dart';
import 'package:mynotes/views/notes_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedViewIndex = 0;

  static const List<Widget> _pages = [
    NotesView(),
    Categories(),
    Text('record'),
    Text('settings'),
  ];

  static const List<BottomNavigationBarItem> _navigationItems = [
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: Icon(
          FontAwesomeIcons.house,
        ),
      ),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: Icon(
          FontAwesomeIcons.solidFileLines,
        ),
      ),
      label: 'Categories',
    ),
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: Icon(
          FontAwesomeIcons.microphone,
        ),
      ),
      label: 'Record',
    ),
    BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 5.0),
        child: Icon(
          FontAwesomeIcons.gear,
        ),
      ),
      label: 'Settings',
    ),
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
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedViewIndex,
      selectedItemColor: const Color(lightBlueHex),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(
        color: const Color(lightBlueHex),
        fontFamily: Theme.of(context).textTheme.labelSmall!.fontFamily,
        fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
      ),
      unselectedLabelStyle: TextStyle(
        color: Colors.grey,
        fontFamily: Theme.of(context).textTheme.labelSmall!.fontFamily,
        fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
      ),
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped,
      items: _navigationItems,
      elevation: 0.7,
    );
  }
}
