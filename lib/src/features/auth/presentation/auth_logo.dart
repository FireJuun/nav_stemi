import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({this.width = 256, super.key});

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

class AuthLogoSubtitle extends StatelessWidget {
  const AuthLogoSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Status: Beta Testing +\n'
      'Seeking Feedback',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      textAlign: TextAlign.center,
    );
  }
}
