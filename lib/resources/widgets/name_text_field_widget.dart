import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class NameTextField extends StatefulWidget {
  final TextEditingController controller;
  const NameTextField({super.key, required this.controller});

  @override
  createState() => _NameTextFieldState();
}

class _NameTextFieldState extends NyState<NameTextField> {
  late FocusNode _nameFocusNode = FocusNode();
  bool isNameFocused = false;

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _nameFocusNode.addListener(() {
      setState(() {
        isNameFocused = _nameFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return NyTextField.compact(
      controller: widget.controller,
      validationRules: "not_empty|max:50",
      labelText: "Full Name",
      labelStyle: GoogleFonts.anekDevanagari(color: const Color(0xFF6D6D6D)),
      autoFocus: false,
      focusNode: _nameFocusNode,
      prefixIcon: Icon(Icons.person, color: Color(0xFF6D6D6D)),
      backgroundColor:
          isNameFocused ? const Color(0xFFF8F5FF) : const Color(0xFFECECEC),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.transparent),
      ),
      style: GoogleFonts.anekDevanagari(fontSize: 14, color: Color(0xFF6D6D6D)),
      contentPadding: EdgeInsets.symmetric(vertical: 19, horizontal: 30),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color(0xFF8F72E4), width: 2),
      ),
    );
  }
}
