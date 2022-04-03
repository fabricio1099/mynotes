import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import '../firebase_options.dart';
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
  late final Future<FirebaseApp> _initializedApp;

  @override
  void initState() {
    _initializedApp = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializedApp,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            d.log('current user: $user');
            if (user == null) {
              return const LoginView();
            } else if (user.emailVerified) {
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


