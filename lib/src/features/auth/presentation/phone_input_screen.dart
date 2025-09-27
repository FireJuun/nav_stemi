import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Screen for phone number input using firebase_ui_auth
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key, this.action});

  final AuthAction? action;

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: PhoneInputScreen(
        headerBuilder: (context, constraints, shrinkOffset) => const AuthLogo(),
        action: widget.action ?? AuthAction.signIn,
        actions: [
          SMSCodeRequestedAction((context, action, flowKey, phone) {
            context.goNamed(
              AppRoute.smsCodeInput.name,
              extra: (action, flowKey),
            );
          }),
        ],
      ),
    );
  }
}
