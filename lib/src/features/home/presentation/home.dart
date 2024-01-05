import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('nav - STEMI'.hardcoded),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  'Click `Go` to begin'.hardcoded,
                  style:
                      textTheme.titleMedium!.apply(fontStyle: FontStyle.italic),
                ),
                gapH24,
                Text(
                  'Click `Add Data`\nto pre-enter info'.hardcoded,
                  style:
                      textTheme.titleMedium!.apply(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                style: textTheme.bodyLarge,
                children: [
                  TextSpan(
                    text: 'FYI',
                    style: textTheme.bodyLarge?.apply(
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
                FilledButton(
                  onPressed: () => context.goNamed(AppRoute.goTo.name),
                  child: Text(
                    '+ GO'.hardcoded,
                    style: textTheme.titleLarge!
                        .apply(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                gapH16,
                OutlinedButton(
                  onPressed: () => context.goNamed(AppRoute.homeAddData.name),
                  child: Text(
                    'Add Data'.hardcoded,
                    style: textTheme.titleLarge!.apply(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
