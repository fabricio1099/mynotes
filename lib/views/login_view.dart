import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/dialogs/loading_dialog.dart';
import 'package:mynotes/utilities/widgets/custom_auth_text_input_field.dart';

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

          switch (exception.runtimeType) {
            case UserNotFoundAuthException:
            case WrongPassswordAuthException:
              await showErrorDialog(
                  context, 'CannotFind a user with the entered credentials!');
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
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraint) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 175,
                        width: 175,
                        child: Image(
                          image: AssetImage(('assets/icon/icon.png')),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        "Hello",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Welcome Back, you've been missed!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(
                        height: 50.0,
                      ),
                      CustomAuthTextInputField(
                        controller: _email,
                        isEmail: true,
                        emailHint: 'Email',
                      ),
                      const SizedBox(height: 10),
                      CustomAuthTextInputField(
                        controller: _password,
                        isPassword: true,
                        passwordHint: 'Password',
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            style: TextButton.styleFrom(
                              splashFactory: NoSplash.splashFactory,
                              alignment: Alignment.centerRight,
                            ),
                            child: const Text(
                              'Forgot password',
                              textAlign: TextAlign.end,
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                    const AuthEventForgotPassword(),
                                  );
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.deepPurpleAccent,
                        ),
                        child: TextButton(
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
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.redAccent,
                        ),
                        child: TextButton(
                          onPressed: () async {
                            context.read<AuthBloc>().add(
                                  const AuthEventShouldRegister(),
                                );
                          },
                          child: const Text(
                            'Create an account',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
