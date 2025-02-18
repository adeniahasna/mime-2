import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class EmailTextField extends StatefulWidget {
  final TextEditingController controller;
  const EmailTextField({super.key, required this.controller});

  @override
  createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends NyState<EmailTextField> {
  late FocusNode _emailFocusNode = FocusNode();
  bool isEmailFocused = false;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _emailFocusNode = FocusNode();
    _emailFocusNode.addListener(() {
      setState(() {
        isEmailFocused = _emailFocusNode.hasFocus;
        if (!isEmailFocused) {
          validateEmail();
        }
      });
    });
  }

  void validateEmail() {
    String value = widget.controller.text;
    if (value.isEmpty) {
      setState(() {
        hasError = true;
        errorMessage = 'Email is required';
      });
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      setState(() {
        hasError = true;
        errorMessage = 'Please enter a valid email';
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
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NyTextField.emailAddress(
          controller: widget.controller,
          focusNode: _emailFocusNode,
          autoFocus: false,
          labelStyle: GoogleFonts.anekDevanagari(
              color: hasError ? Color(0xFFB20D0D) : const Color(0xFF6D6D6D)),
          prefixIcon: Icon(Icons.email,
              color: hasError ? Color(0xFFB20D0D) : Color(0xFF6D6D6D)),
          backgroundColor: isEmailFocused
              ? const Color(0xFFF8F5FF)
              : const Color(0xFFECECEC),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide:
                BorderSide(color: hasError ? Colors.red : Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
                color: hasError ? Color(0xFFB20D0D) : const Color(0xFF8F72E4),
                width: 2),
          ),
          style: GoogleFonts.anekDevanagari(
              fontSize: 14,
              color: hasError ? Color(0xFFB20D0D) : Color(0xFF6D6D6D)),
          contentPadding: EdgeInsets.symmetric(vertical: 19, horizontal: 30),
          validationRules: "not_empty|email",
          onChanged: (value) {
            // Validate on every change
            validateEmail();
          },
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
