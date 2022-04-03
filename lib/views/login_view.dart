import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'dart:developer' as d show log;

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
                final userCredentials =
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                d.log('$userCredentials');
                Navigator.of(context).pushNamedAndRemoveUntil(
                  NotesView.routeName,
                  (route) => false,
                );
              } on FirebaseAuthException catch (e) {
                d.log(e.code);
                switch (e.code) {
                  case 'user-not-found':
                    d.log('User not found');
                    break;
                  case 'wrong-password':
                    d.log('Wrong password');
                    break;
                  default:
                    d.log(e.code);
                    break;
                }
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
