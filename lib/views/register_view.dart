import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import 'package:mynotes/utilities/widgets/custom_text_input_field.dart';
import '../services/auth/bloc/auth_bloc.dart';
import '../services/auth/bloc/auth_state.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          final exception = state.exception;
          switch (exception.runtimeType) {
            case WeakPasswordAuthException:
              await showErrorDialog(context, 'Weak password');
              break;
            case EmailAlreadyInUseAuthException:
              await showErrorDialog(context, 'Email already in use');
              break;
            case InvalidEmailAuthException:
              await showErrorDialog(context, 'Invalid email');
              break;
            case GenericAuthException:
              await showErrorDialog(context, 'Failed to register');
              break;
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "MyNotes",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 36.0,
                            ),
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                            height: 70,
                            width: 70,
                            child: Image(
                              image: AssetImage(('assets/icon/icon.png')),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Here you can create your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          // fontWeight: FontWeight.w400,
                          fontSize: 17.0,
                        ),
                      ),
                      const Spacer(),
                      CustomTextInputField(
                        controller: _email,
                        isEmail: true,
                        emailHint: 'Email',
                      ),
                      const SizedBox(height: 10),
                      CustomTextInputField(
                        controller: _password,
                        isPassword: true,
                        passwordHint: 'Password',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.redAccent,
                        ),
                        child: TextButton(
                          onPressed: () async {
                            final email = _email.text;
                            final password = _password.text;
                            context
                                .read<AuthBloc>()
                                .add(AuthEventRegister(email, password));
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
                      const Spacer(),
                      TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: const Text(
                          'Already registered? Login here!',
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () {
                          context.read<AuthBloc>().add(const AuthEventLogOut());
                        },
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
