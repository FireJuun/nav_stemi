import 'package:flutter/material.dart';

/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course
///
/// Primary button based on [ElevatedButton]. Useful for CTAs in the app.
class PrimaryLoadingButton extends StatelessWidget {
  /// Create a PrimaryElevatedButton.
  /// if [isLoading] is true, a loading indicator will be displayed instead of
  /// the text.
  const PrimaryLoadingButton({
    required this.text,
    super.key,
    this.isLoading = false,
    this.onPressed,
  });
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: isLoading
          ? const CircularProgressIndicator()
          : Text(text, textAlign: TextAlign.center),
    );
  }
}
