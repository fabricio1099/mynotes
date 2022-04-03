import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';
import 'package:mynotes/views/login_view.dart';
import 'dart:developer' as d;

import 'package:mynotes/views/verify_email_view.dart';

class RegisterView extends StatefulWidget {
  static const routeName = '/register';

  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text('Register'),
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
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                final user = FirebaseAuth.instance.currentUser;
                user?.sendEmailVerification();
                Navigator.of(context).pushNamed(VerifyEmailView.routeName);
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case 'weak-password':
                    showErrorDialog(context, 'Weak password');
                    break;
                  case 'email-already-in-use':
                    showErrorDialog(context, 'Email already in use');
                    break;
                  case 'invalid-email':
                    showErrorDialog(context, 'Invalid email');
                    break;
                  case 'operation-not-allowed':
                    showErrorDialog(context, 'Operation not allowed');
                    break;
                  default:
                    d.log(e.code);
                    break;
                }
              } on Exception catch (e) {
                d.log(e.toString());
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            child: const Text('Already registered? Login here!'),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                LoginView.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
