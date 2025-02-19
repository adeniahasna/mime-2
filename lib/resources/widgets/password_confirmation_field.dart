import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PasswordConfirmationField extends StatefulWidget {
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Function(bool) onValidateChange;

  const PasswordConfirmationField({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onValidateChange,
  });

  @override
  createState() => _PasswordConfirmationFieldState();
}

class _PasswordConfirmationFieldState
    extends NyState<PasswordConfirmationField> {
  late FocusNode _confirmPassFocusNode = FocusNode();
  bool isPasswordVisible = false;
  bool isConfirmPassFocused = false;

  @override
  void initState() {
    super.initState();
    _confirmPassFocusNode = FocusNode();
    _confirmPassFocusNode.addListener(() {
      setState(() {
        isConfirmPassFocused = _confirmPassFocusNode.hasFocus;
      });
    });

    checkPasswordMatch(
        widget.passwordController.text, widget.confirmPasswordController.text);
    widget.confirmPasswordController.addListener(() {
      checkPasswordMatch(widget.passwordController.text,
          widget.confirmPasswordController.text);
    });
  }

  @override
  void dispose() {
    _confirmPassFocusNode.dispose();
    super.dispose();
  }

  void checkPasswordMatch(String password, String confirmPassword) {
    bool isMatch = password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;
    widget.onValidateChange(isMatch);
  }

  @override
  Widget view(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NyTextField.password(
          controller: widget.confirmPasswordController,
          obscureText: !isPasswordVisible,
          autoFocus: false,
          labelText: "Confirm Password",
          labelStyle:
              GoogleFonts.anekDevanagari(color: const Color(0xFF6D6D6D)),
          passwordViewable: true,
          focusNode: _confirmPassFocusNode,
          prefixIcon: Icon(Icons.lock, color: Color(0xFF6D6D6D)),
          backgroundColor: isConfirmPassFocused
              ? const Color(0xFFF8F5FF)
              : const Color(0xFFECECEC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: const Color(0xFF8F72E4), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 19, horizontal: 30),
          style: GoogleFonts.anekDevanagari(
            fontSize: 14,
            color: Color(0xFF6D6D6D),
          ),
          validationRules: "not_empty",
          validationErrorMessage: "Passwords do not match",
          validateOnFocusChange: true,
          enableSuggestions: true,
          onChanged: (value) {
            checkPasswordMatch(widget.passwordController.text, value);
          },
        ),
      ],
    );
  }
}
