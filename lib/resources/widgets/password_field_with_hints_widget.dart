import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PasswordFieldWithHints extends StatefulWidget {
  final TextEditingController controller;
  final Function(bool, bool, bool) onValidateChange;

  const PasswordFieldWithHints({
    super.key,
    required this.controller,
    required this.onValidateChange,
  });

  @override
  createState() => _PasswordFieldWithHintsState();
}

class _PasswordFieldWithHintsState extends NyState<PasswordFieldWithHints> {
  late FocusNode _passFocusNode = FocusNode();
  bool isPasswordVisible = false;
  bool isPassFocused = false;

  @override
  void initState() {
    super.initState();
    _passFocusNode = FocusNode();
    _passFocusNode.addListener(() {
      setState(() {
        isPassFocused = _passFocusNode.hasFocus;
      });
    });

    checkPasswordCriteria(widget.controller.text);
    widget.controller.addListener(() {
      checkPasswordCriteria(widget.controller.text);
    });
  }

  @override
  void dispose() {
    _passFocusNode.dispose();
    super.dispose();
  }

  void checkPasswordCriteria(String value) {
    bool hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(value);
    bool hasValidLength = value.length >= 8 && value.length <= 20;

    widget.onValidateChange(hasUpperCase, hasDigit, hasValidLength);
  }

  @override
  Widget view(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NyTextField.password(
          controller: widget.controller,
          obscureText: !isPasswordVisible,
          autoFocus: false,
          labelStyle:
              GoogleFonts.anekDevanagari(color: const Color(0xFF6D6D6D)),
          passwordViewable: true,
          focusNode: _passFocusNode,
          prefixIcon: Icon(Icons.lock, color: Color(0xFF6D6D6D)),
          backgroundColor:
              isPassFocused ? const Color(0xFFF8F5FF) : const Color(0xFFECECEC),
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
          validationRules: "not_empty|min:8|max:20|password_v1",
          validationErrorMessage:
              "Password must contain at least 1 uppercase letter, 1 number, and 8 characters",
          validateOnFocusChange: true,
          enableSuggestions: true,
          onChanged: (value) {
            checkPasswordCriteria(value);
          },
        ),
      ],
    );
  }
}
