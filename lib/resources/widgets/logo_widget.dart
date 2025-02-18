import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, required this.height, required this.width});
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "mime_logo.png",
      height: height,
      width: width,
    ).localAsset();
  }
}

// ignore: must_be_immutable
class LogoWhite extends StatelessWidget {
  double height;
  double width;
  LogoWhite({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "mime_white_logo.png",
      height: height,
      width: width,
    ).localAsset();
  }
}
