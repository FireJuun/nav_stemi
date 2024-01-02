import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'nav - STEMI'.hardcoded,
          style: Theme.of(context).textTheme.displayMedium,
        ),
      ),
      body: const Center(child: Text('center')),
    );
  }
}
