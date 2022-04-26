import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/new_notes_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'dart:developer' as d show log;

import 'views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        RegisterView.routeName: (context) => const RegisterView(),
        LoginView.routeName: (context) => const LoginView(),
        NotesView.routeName: (context) => const NotesView(),
        VerifyEmailView.routeName: (context) => const VerifyEmailView(),
        NewNotesView.routeName: (context) => const NewNotesView(),
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUSer;
            if (user == null) {
              return const LoginView();
            } else if (user.isEmailVerified) {
              d.log('You are a verified user');
              return const NotesView();
            } else {
              d.log('You need to verify your email first !');
              return const VerifyEmailView();
            }
          default:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                Text('Loading...'),
              ],
            );
        }
      },
    );
  }
}
