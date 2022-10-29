import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class CustomTextInputField extends StatelessWidget {
  const CustomTextInputField(
      {Key? key,
      required this.controller,
      this.isPassword,
      this.isEmail,
      this.emailHint,
      this.passwordHint})
      : super(key: key);

  final TextEditingController controller;
  final bool? isPassword;
  final bool? isEmail;
  final String? emailHint;
  final String? passwordHint;

  @override
  Widget build(BuildContext context) {
    String? hintText = '';
    TextInputType? keyboardType;
    bool showPasswordVisibilityIcon = false;
    bool showPassword = false;
    if (isPassword != null && isPassword! && passwordHint != null) {
      hintText = passwordHint;
      keyboardType = TextInputType.emailAddress;
      showPasswordVisibilityIcon = true;
    }
    if (isEmail != null && isEmail! && emailHint != null) {
      hintText = emailHint;
      keyboardType = TextInputType.visiblePassword;
    }

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedOut) {
          showPassword = state.showPassword;
        }
      },
      builder: (context, state) => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: TextField(
                  controller: controller,
                  obscureText: (isPassword != null && isPassword!)
                      ? !showPassword
                      : false,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (showPasswordVisibilityIcon)
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: !showPassword
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                  color: Colors.grey.shade600,
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          AuthEventLoginShowPassword(
                            !showPassword,
                          ),
                        );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
