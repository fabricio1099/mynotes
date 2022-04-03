import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as d;

import 'package:mynotes/views/register_view.dart';

class VerifyEmailView extends StatefulWidget {
  static String routeName = '/verify-email';

  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Column(
        children: [
          const Text("We've sent you an email verification. Please open it to verify your account"),
          const Text("If you haven't received a verification email yet, press the button below"),
          TextButton(
            child: const Text('Send email verification'),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
          ),
          TextButton(
            child: const Text('Restart'),
            onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushNamedAndRemoveUntil(RegisterView.routeName, (route) => false)  ;
            },
          ),
        ],
      ),
    );
  }
}