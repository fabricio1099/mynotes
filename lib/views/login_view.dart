import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  static const routeName = '/login';

  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final exception = state.exception;
          final closeDialog = _closeDialogHandle;

          if(!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else  if(state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: 'Loading...',
            );
          }

          // if (exception is UserNotFoundAuthException) {
          //   await showErrorDialog(context, 'User not found');
          // } else if (exception is WrongPassswordAuthException) {
          //   await showErrorDialog(context, 'Wrong credentials');
          // } else if (exception is InvalidEmailAuthException) {
          //   await showErrorDialog(context, 'Invalid email');
          // } else if (exception is UserDisabledAuthException) {
          //   await showErrorDialog(context, 'User disabled');
          // } else if (exception is GenericAuthException) {
          //   await showErrorDialog(context, 'Authentication Error');
          // }

          switch (exception.runtimeType) {
            case UserNotFoundAuthException:
            // await showErrorDialog(context, 'User not found');
            // break;
            case WrongPassswordAuthException:
              await showErrorDialog(context, 'Wrong credentials');
              break;
            case InvalidEmailAuthException:
              await showErrorDialog(context, 'Invalid email');
              break;
            case UserDisabledAuthException:
              await showErrorDialog(context, 'User disabled');
              break;
            case GenericAuthException:
              await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
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
                context.read<AuthBloc>().add(
                      AuthEventLogIn(
                        email,
                        password,
                      ),
                    );
              },
              child: const Text('Login'),
            ),
            TextButton(
              child: const Text('Not registered yet? Register here!'),
              onPressed: () {
                context.read<AuthBloc>().add(
                      const AuthEventShouldRegister(),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
