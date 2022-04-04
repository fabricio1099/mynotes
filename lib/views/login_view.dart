import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'dart:developer' as d show log;

import 'package:mynotes/views/verify_email_view.dart';

class LoginView extends StatefulWidget {
  static const routeName = '/login';

  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here',
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                if (user?.emailVerified ?? false) {
                  // user's email is verified
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    NotesView.routeName,
                    (route) => false,
                  );
                } else {
                  // user's email is not verified
                  await showErrorDialog(
                    context,
                    'You need to verify your email before signing in !',
                  );
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamed(
                    VerifyEmailView.routeName,
                  );
                }
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case 'user-not-found':
                    await showErrorDialog(context, 'User not found');
                    break;
                  case 'wrong-password':
                    await showErrorDialog(context, 'Wrong credentials');
                    break;
                  case 'invalid-email':
                    await showErrorDialog(context, 'Invalid email');
                    break;
                  case 'user-disabled':
                    await showErrorDialog(context, 'User disabled');
                    break;
                  default:
                    d.log(e.code);
                    break;
                }
              } on Exception catch (e) {
                d.log(e.toString());
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            child: const Text('Not registered yet? Register here!'),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                RegisterView.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
