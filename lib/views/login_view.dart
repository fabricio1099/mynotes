import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
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
                AuthService.firebase().signIn(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUSer;
                d.log('xyz : $user');
                if (user != null) {
                  d.log('user not nullll');
                  if (user.isEmailVerified) {
                    // user's email is verified
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      NotesView.routeName,
                      (route) => false,
                    );
                  } else {
                    // user's email is not verified
                    d.log('$user');
                    // await showErrorDialog(
                    //   context,
                    //   'You need to verify your email before signing in !',
                    // );
                    // await AuthService.firebase().signOut();
                    Navigator.of(context).pushNamed(
                      VerifyEmailView.routeName,
                    );
                  }
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(context, 'User not found');
              } on WrongPassswordAuthException {
                await showErrorDialog(context, 'Wrong credentials');
              } on InvalidEmailAuthException {
                await showErrorDialog(context, 'Invalid email');
              } on UserDisabledAuthException {
                await showErrorDialog(context, 'User disabled');
              } on GenericAuthException {
                await showErrorDialog(context, 'Authentication Error');
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
