import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Screen for SMS code input using firebase_ui_auth
class SMSInputScreen extends StatefulWidget {
  const SMSInputScreen({
    required this.flowKey,
    super.key,
    this.action,
  });

  final Object flowKey;
  final AuthAction? action;

  @override
  State<SMSInputScreen> createState() => _SMSInputScreenState();
}

class _SMSInputScreenState extends State<SMSInputScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SMSCodeInputScreen(
          headerBuilder: (context, constraints, shrinkOffset) =>
              const AuthLogo(),
          actions: [
            AuthStateChangeAction<SignedIn>((context, state) {
              debugPrint('User signed in: ${state.user?.uid}');
            }),
          ],
          flowKey: widget.flowKey,
          action: widget.action,
        );
      },
    );
  }
}
