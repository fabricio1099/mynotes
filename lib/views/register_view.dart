import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynotes/views/login_view.dart';
import 'dart:developer' as d;

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
                final userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                d.log('user credential: $userCredential');
              } on FirebaseAuthException catch (e) {
                d.log(e.code);
                switch (e.code) {
                  case 'weak-password':
                    d.log('Weak password');
                    break;
                  case 'email-already-in-use':
                    d.log('Email already in use');
                    break;
                  case 'invalid-email':
                    d.log('Invalid email');
                    break;
                  default:
                    d.log('code: ${e.code}');
                    break;
                }
              } on Exception {
                d.log('something bad happened');
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            child: const Text('Already registered? Login here!'),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(LoginView.routeName, (route) => false,);
            },
          ),
        ],
      ),
    );
  }
}
