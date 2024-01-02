import 'package:flutter/material.dart';
import 'package:nav_stemi/src/features/home/home.dart';

class App extends StatelessWidget {
  const App({super.key});

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
