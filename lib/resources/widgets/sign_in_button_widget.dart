import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/auth_controller.dart';
import 'package:flutter_app/resources/pages/bottom_nav_bar_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SignInButton extends StatefulWidget {
  final TextEditingController controllerEmail;
  final TextEditingController controllerPassword;
  const SignInButton({
    super.key,
    required this.controllerEmail,
    required this.controllerPassword,
  });

  @override
  createState() => _SignInButtonState();
}

class _SignInButtonState extends NyState<SignInButton> {
  final AuthController _authController = AuthController();
  bool isValid = false;

  @override
  void initState() {
    super.initState();

    widget.controllerEmail.addListener(updateButtonState);
    widget.controllerPassword.addListener(updateButtonState);
  }

  @override
  void dispose() {
    widget.controllerEmail.removeListener(updateButtonState);
    widget.controllerPassword.removeListener(updateButtonState);

    super.dispose();
  }

  void updateButtonState() {
    setState(() {
      isValid = widget.controllerEmail.text.isNotEmpty &&
          widget.controllerPassword.text.isNotEmpty;
    });
  }

  void _login() async {
    String? errorMessage = await _authController.login(
      widget.controllerEmail.text,
      widget.controllerPassword.text,
    );

    if (errorMessage == null) {
      showToastNotification(context,
          title: "Login Berhasil", description: "Selamat datang!");
      Navigator.pushReplacementNamed(context, BottomNavBarPage.path.name);
    } else {
      showToastNotification(context, title: "Error", description: errorMessage);
    }
  }

  @override
  Widget view(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        if (isValid) {
          _login();
          NyLogger.info("Sign In");
        }
      },
      color: isValid ? Color(0xFF4413D2) : Color(0xFFD1C8FF),
      textColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 13, horizontal: 135),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Sign In",
        style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.anekDevanagari().fontFamily),
      ),
    );
  }
}
