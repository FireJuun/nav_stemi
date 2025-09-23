import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({this.width = 128, super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final logo = isDarkMode
        ? 'assets/logos/nav_stemi_logo_dark.png'
        : 'assets/logos/nav_stemi_logo_light.png';

    return SizedBox(
      width: width,
      child: Center(
        child: Image.asset(logo),
      ),
    );
  }
}
