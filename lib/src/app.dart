import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
