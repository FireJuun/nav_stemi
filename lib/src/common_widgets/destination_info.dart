import 'package:flutter/material.dart';

class DestinationInfo extends StatelessWidget {
  const DestinationInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Destination:',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Expanded(
          child: Text(
            'Scotland Memorial',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
