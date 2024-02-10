import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class EtaWidget extends StatelessWidget {
  const EtaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            'ETA:'.hardcoded,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            '24 min'.hardcoded,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '7:13 pm'.hardcoded,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleSmall?.apply(
                  // fontWeightDelta: 2,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
      ],
    );
  }
}
