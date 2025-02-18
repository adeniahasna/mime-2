import 'package:flutter/material.dart';
import 'package:flutter_app/config/assets_image.dart';
import 'package:flutter_app/resources/pages/sign_in_page.dart';
import 'package:flutter_app/resources/widgets/email_text_field_widget.dart';
import 'package:flutter_app/resources/widgets/logo_widget.dart';
import 'package:flutter_app/resources/widgets/name_text_field_widget.dart';
import 'package:flutter_app/resources/widgets/password_field_with_hints_widget.dart';
import 'package:flutter_app/resources/widgets/sign_up_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';

class SignUpPage extends NyStatefulWidget {
  static RouteView path = ("/sign-up", (_) => SignUpPage());

  SignUpPage({super.key}) : super(child: () => _SignUpPageState());
}

class _SignUpPageState extends NyPage<SignUpPage> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  late FocusNode _nameFocusNode = FocusNode();
  late FocusNode _emailFocusNode = FocusNode();
  late FocusNode _passFocusNode = FocusNode();
  bool isEmailFocused = false;
  bool isPassFocused = false;
  bool isNameFocused = false;
  bool hasUpperCase = false;
  bool hasDigit = false;
  bool hasValidLength = false;

  void setupFocusListener() {
    _nameFocusNode.addListener(() {
      if (mounted) {
        updateState(() {
          isNameFocused = _nameFocusNode.hasFocus;
        });
      }
    });

    _emailFocusNode.addListener(() {
      if (mounted) {
        updateState(() {
          isEmailFocused = _emailFocusNode.hasFocus;
        });
      }
    });

    _passFocusNode.addListener(() {
      if (mounted) {
        updateState(() {
          isPassFocused = _passFocusNode.hasFocus;
        });
      }
    });
  }

  void updatePasswordValidation(bool upper, bool digit, bool minLength) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        hasUpperCase = upper;
        hasDigit = digit;
        hasValidLength = minLength;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                authBG(),
                logoWhite(),
                taglineText(),
                signInForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget authBG() {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.white), // Background putih
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(AssetImages.authCurva),
          ),
        ],
      ),
    );
  }

  Widget logoWhite() {
    return Align(
      alignment: Alignment(0, -0.9),
      child: LogoWhite(height: 150, width: 200),
    );
  }

  Widget taglineText() {
    return Positioned(
      top: 170,
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: 300,
          child: Text(
            "Let's create, manage, and complete your tasks together !",
            style:
                GoogleFonts.anekDevanagari(fontSize: 18, color: Colors.white),
          ).alignCenter().fontWeightLight(),
        ),
      ),
    );
  }

  Widget signInForm() {
    return Positioned(
      top: 335,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          width: 360,
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              textTitle(),
              SizedBox(height: 20),
              NameTextField(controller: controllerName),
              SizedBox(height: 22),
              EmailTextField(controller: controllerEmail),
              SizedBox(height: 22),
              PasswordFieldWithHints(
                  controller: controllerPassword,
                  onValidateChange: updatePasswordValidation),
              SizedBox(height: 10),
              validateText(),
              SizedBox(height: 13),
              SignUpButton(
                  controllerName: controllerName,
                  controllerEmail: controllerEmail,
                  controllerPassword: controllerPassword),
              SizedBox(height: 2),
              haveAccount()
            ],
          ),
        ),
      ),
    );
  }

  Widget validateText() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "*  8 - 20 characters",
              style: GoogleFonts.anekDevanagari(
                fontSize: 13,
                color: hasValidLength ? Color(0xFF4413D2) : Color(0xFFD1C8FF),
              ),
            ),
            SizedBox(height: 3),
            Text(
              "* At least one number",
              style: GoogleFonts.anekDevanagari(
                fontSize: 13,
                color: hasDigit ? Color(0xFF4413D2) : Color(0xFFD1C8FF),
              ),
            ),
            SizedBox(height: 3),
            Text(
              "* At least one uppercase letter",
              style: GoogleFonts.anekDevanagari(
                fontSize: 13,
                color: hasUpperCase ? Color(0xFF4413D2) : Color(0xFFD1C8FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textTitle() {
    return Text(
      "Sign Up",
      style: GoogleFonts.anekDevanagari(
          fontSize: 32, color: Colors.black, fontWeight: FontWeight.w500),
    ).alignCenter();
  }

  Widget haveAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account?", style: GoogleFonts.anekDevanagari()),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              SignInPage.path.name,
            );
          },
          child: Text(
            "Sign In",
            style: TextStyle(
              color: Colors.indigo[600],
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.anekDevanagari().fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
