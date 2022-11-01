import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:mynotes/utilities/widgets/custom_auth_text_input_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentPasswordDialog(context);
          }
          if (state.exception != null) {
            final exceptionType = state.exception.runtimeType;
            String errorMessage =
                'We could not process your request. Please make sure you are a registered user. If not, register now!';
            if (exceptionType is UserNotFoundAuthException) {
              errorMessage =
                  'We could not find that user. Please register now!';
            } else if (exceptionType is InvalidEmailAuthException) {
              errorMessage =
                  'The entered email is invalid. Please check it before trying again.';
            }
            await showErrorDialog(
              context,
              errorMessage,
            );
          }
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(builder: (context, constraint) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraint.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 175,
                        width: 175,
                        child: Image(
                          image: AssetImage('assets/icon/icon-locker.png'),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Enter your email address and we will send you a link to reset your password.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      CustomAuthTextInputField(
                        controller: _controller,
                        isEmail: true,
                        emailHint: 'Email',
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.deepPurpleAccent,
                        ),
                        child: TextButton(
                          onPressed: () async {
                            final email = _controller.text;
                            context.read<AuthBloc>().add(
                                  AuthEventForgotPassword(
                                    email: email,
                                  ),
                                );
                          },
                          child: const Text(
                            'Reset my password',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                                const AuthEventLogOut(),
                              );
                        },
                        child: const Text(
                          'Back to login page',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
