import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'nav - STEMI'.hardcoded,
          style: textTheme.displayMedium,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Click `Go` to begin'.hardcoded,
                  style: textTheme.bodyLarge,
                ),
                Text(
                  'Click `Add Data` to pre-enter info'.hardcoded,
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'FYI',
                    style: textTheme.bodyMedium?.apply(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: ': '.hardcoded),
                  TextSpan(text: 'You can modify info at anytime'.hardcoded),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('+ GO')),
                OutlinedButton(onPressed: () {}, child: const Text('Add Data')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
