import 'package:flutter/material.dart';
import 'package:mynotes/constants/colors.dart';
import 'package:mynotes/views/notes/profile_view.dart';

class CustomNoteViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNoteViewAppBar({
    Key? key,
    required this.context,
  }) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 15,
        bottom: 20,
      ),
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
              backgroundColor: const Color(veryPaleBlueHex),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(100);
}