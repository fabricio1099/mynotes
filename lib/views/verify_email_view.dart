import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as d;

class VerifyEmailView extends StatefulWidget {
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
          const Text('Please verify your email'),
          TextButton(
            child: const Text('Send email verification'),
            onPressed: () async {
              d.log('verify email');
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
          ),
        ],
      ),
    );
  }
}