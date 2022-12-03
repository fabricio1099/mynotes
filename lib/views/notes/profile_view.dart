import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/helpers/loading/loading_screen.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 200,
                width: 200,
                child: CircleAvatar(
                  backgroundColor: Colors.amber,
                ),
              ),
              TextButton(
                onPressed: () async {
                  // print('logout');
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    try {
                      context.read<AuthBloc>().add(
                            const AuthEventLogOut(),
                          );
                    } on UserNotLoggedInAuthException {
                      await showErrorDialog(context, "You're not logged in!");
                    } on GenericAuthException {
                      await showErrorDialog(context, 'Failed to log out');
                    }
                  }
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
