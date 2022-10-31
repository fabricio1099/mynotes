import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class CustomTextInputField extends StatefulWidget {
  const CustomTextInputField({
    Key? key,
    required this.controller,
    this.isPassword,
    this.isConfirmPassword,
    this.isEmail,
    this.emailHint,
    this.passwordHint,
    this.confirmPasswordHint,
  }) : super(key: key);

  final TextEditingController controller;
  final bool? isPassword;
  final bool? isConfirmPassword;
  final bool? isEmail;
  final String? emailHint;
  final String? passwordHint;
  final String? confirmPasswordHint;

  @override
  State<CustomTextInputField> createState() => _CustomTextInputFieldState();
}

class _CustomTextInputFieldState extends State<CustomTextInputField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    String? hintText = '';
    TextInputType? keyboardType;
    bool showPasswordVisibilityIcon = false;
    if (widget.isPassword != null &&
        widget.isPassword! &&
        widget.passwordHint != null) {
      hintText = widget.passwordHint;
      keyboardType = TextInputType.visiblePassword;
      showPasswordVisibilityIcon = true;
    }
    if (widget.isConfirmPassword != null &&
        widget.isConfirmPassword! &&
        widget.confirmPasswordHint != null) {
      hintText = widget.confirmPasswordHint;
      keyboardType = TextInputType.visiblePassword;
      showPasswordVisibilityIcon = true;
    }
    if (widget.isEmail != null && widget.isEmail! && widget.emailHint != null) {
      hintText = widget.emailHint;
      keyboardType = TextInputType.emailAddress;
    }

    return Container(
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
                controller: widget.controller,
                obscureText: !_showPassword,
                // (widget.isPassword != null && widget.isPassword!)
                //     ? !showPassword
                //     : false,
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
                icon: !_showPassword //!showPassword
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                color: Colors.grey.shade600,
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                  // context.read<AuthBloc>().add(
                  //       AuthEventLoginShowPassword(
                  //         !showPassword,
                  //       ),
                  //     );
                },
              ),
          ],
        ),
      ),
    );
  }
}
