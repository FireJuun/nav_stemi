import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Similar to [PrimaryLoadingButton], but rather than toggling
/// between loading states, this button toggles between active
/// (FilledButton) and inactive (OutlinedButton) states
class PrimaryToggleButton extends StatelessWidget {
  const PrimaryToggleButton({
    required this.text,
    super.key,
    this.isActive = false,
    this.onPressed,
  });

  final String text;
  final bool isActive;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 300.ms,

      /// required due to this bug: https://github.com/flutter/flutter/issues/121336#issuecomment-1482620874
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: isActive
          ? FilledButton(
              onPressed: onPressed,
              child: Text(text),
            )
          : OutlinedButton(
              onPressed: onPressed,
              child: Text(text),
            ),
    );
  }
}
