import 'package:flutter/material.dart';
import 'package:flutter_app/app/controllers/auth_controller.dart';
import 'package:flutter_app/resources/pages/sign_in_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SignUpButton extends StatefulWidget {
  final TextEditingController controllerName;
  final TextEditingController controllerEmail;
  final TextEditingController controllerPassword;
  final TextEditingController controllerConfirmPassword;

  const SignUpButton({
    super.key,
    required this.controllerName,
    required this.controllerEmail,
    required this.controllerPassword,
    required this.controllerConfirmPassword,
  });

  @override
  createState() => _SignUpButtonState();
}

class _SignUpButtonState extends NyState<SignUpButton> {
  final AuthController _authController = AuthController();
  bool isValid = false;
  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  void initState() {
    super.initState();

    widget.controllerName.addListener(updateButtonState);
    widget.controllerEmail.addListener(updateButtonState);
    widget.controllerPassword.addListener(updateButtonState);
    widget.controllerConfirmPassword.addListener(updateButtonState);
  }

  Future<void> _register() async {
    String name = widget.controllerName.text;
    String email = widget.controllerEmail.text;
    String password = widget.controllerPassword.text;

    // Panggil metode register dari AuthController
    String? errorMessage =
        await _authController.register(name, email, password);

    if (errorMessage == null) {
      showToastNotification(context,
          title: "Registrasi Berhasil!", description: "Silakan login.");
      Navigator.pushNamed(
        context,
        SignInPage.path.name,
      );
    } else {
      showToastNotification(context, title: "Error", description: errorMessage);
    }
  }

  @override
  void dispose() {
    widget.controllerName.removeListener(updateButtonState);
    widget.controllerEmail.removeListener(updateButtonState);
    widget.controllerPassword.removeListener(updateButtonState);
    widget.controllerConfirmPassword.removeListener(updateButtonState);

    super.dispose();
  }

  void updateButtonState() {
    setState(() {
      isValid = widget.controllerName.text.isNotEmpty &&
          widget.controllerPassword.text.isNotEmpty &&
          widget.controllerEmail.text.isNotEmpty &&
          widget.controllerConfirmPassword.text.isNotEmpty;
    });
  }

  @override
  Widget view(BuildContext context) {
    return Column(
      children: [
        MaterialButton(
          onPressed: () {
            String name = widget.controllerName.text;
            String email = widget.controllerEmail.text;
            String password = widget.controllerPassword.text;
            String confirmPassword = widget.controllerConfirmPassword.text;
            if (widget.controllerPassword.text !=
                widget.controllerConfirmPassword.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Passwords do not match"),
                ),
              );
              return;
            }
            validate(
              rules: {
                "name": [name, "not_empty"],
                "email": [email, "not_empty|email"],
                "password": [password, "not_empty|min:8|password_v1"],
                "confirmPassword": [confirmPassword, "not_empty|min:8"]
              },
              onSuccess: () {
                setState(() {
                  nameError = null;
                  emailError = null;
                  passwordError = null;
                  confirmPasswordError = null;
                });
                NyLogger.info("Sign up button pressed!");
                print(
                    "Name: $name, Email: $email, Password: $password, confirmPassword: $confirmPassword");
                _register();
              },
              onFailure: (Exception exception) {
                setState(() {
                  print('No match found');
                });
              },
              showAlert: true,
              alertStyle: ToastNotificationStyleType.danger,
            );
            NyLogger.info("Sign in button pressed !");
          },
          color: isValid ? Color(0xFF4413D2) : Color(0xFFD1C8FF),
          textColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 107),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Create Account",
            style: GoogleFonts.anekDevanagari(
                fontSize: 19, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
