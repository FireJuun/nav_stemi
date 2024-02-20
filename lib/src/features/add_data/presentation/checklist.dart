import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class Checklist extends StatelessWidget {
  const Checklist({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        child: Center(
          child: Text('Checklist...'.hardcoded),
        ),
      ),
    );
  }
}
