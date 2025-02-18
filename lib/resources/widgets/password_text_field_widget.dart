import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordTextField({super.key, required this.controller});

  @override
  createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends NyState<PasswordTextField> {
  late FocusNode _passFocusNode = FocusNode();
  bool isPasswordVisible = false;
  bool isPassFocused = false;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _passFocusNode = FocusNode();
    _passFocusNode.addListener(() {
      setState(() {
        isPassFocused = _passFocusNode.hasFocus;

        if (!isPassFocused) {
          validatePass();
        }
      });
    });
  }

  void validatePass() {
    String value = widget.controller.text;
    if (value.isEmpty) {
      setState(() {
        hasError = true;
        errorMessage = 'Password is required';
      });
    } else {
      setState(() {
        hasError = false;
        errorMessage = null;
      });
    }
  }

  @override
  void dispose() {
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NyTextField.password(
          controller: widget.controller,
          obscureText: !isPasswordVisible,
          focusNode: _passFocusNode,
          labelStyle: GoogleFonts.anekDevanagari(
              color: hasError ? Color(0xFFB20D0D) : const Color(0xFF6D6D6D)),
          autoFocus: false,
          passwordViewable: true,
          prefixIcon: Icon(Icons.lock,
              color: hasError ? Color(0xFFB20D0D) : Color(0xFF6D6D6D)),
          backgroundColor:
              isPassFocused ? const Color(0xFFF8F5FF) : const Color(0xFFECECEC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
                color: hasError ? Color(0xFFB20D0D) : Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
                color: hasError ? Color(0xFFB20D0D) : const Color(0xFF8F72E4),
                width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 19, horizontal: 30),
          style: GoogleFonts.anekDevanagari(
            fontSize: 14,
            color: hasError ? Color(0xFFB20D0D) : Color(0xFF6D6D6D),
          ),
          validationRules: "not_empty",
          decoration: InputDecoration(),
        ),
        if (hasError && errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 5),
            child: Text(
              errorMessage!,
              style: GoogleFonts.anekDevanagari(
                fontSize: 12,
                color: const Color(0xFFB20D0D),
              ),
            ),
          ),
      ],
    );
  }
}
