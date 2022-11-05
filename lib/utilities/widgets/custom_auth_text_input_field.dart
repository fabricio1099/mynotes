import 'package:flutter/material.dart';

class CustomAuthTextInputField extends StatefulWidget {
  const CustomAuthTextInputField({
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
  State<CustomAuthTextInputField> createState() => _CustomAuthTextInputFieldState();
}

class _CustomAuthTextInputFieldState extends State<CustomAuthTextInputField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    String? hintText = '';
    TextInputType? keyboardType;
    bool showPasswordVisibilityIcon = false;
    bool isPasswordOrConfirmPassword = false;
    if (widget.isPassword != null &&
        widget.isPassword! &&
        widget.passwordHint != null) {
      hintText = widget.passwordHint;
      keyboardType = TextInputType.visiblePassword;
      showPasswordVisibilityIcon = true;
      isPasswordOrConfirmPassword = true;
    }
    if (widget.isConfirmPassword != null &&
        widget.isConfirmPassword! &&
        widget.confirmPasswordHint != null) {
      hintText = widget.confirmPasswordHint;
      keyboardType = TextInputType.visiblePassword;
      showPasswordVisibilityIcon = true;
      isPasswordOrConfirmPassword = true;
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
                obscureText: isPasswordOrConfirmPassword && !_showPassword,
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
                },
              ),
          ],
        ),
      ),
    );
  }
}
