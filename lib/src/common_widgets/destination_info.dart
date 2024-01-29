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
            'Scotland Memorial ED',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO(FireJuun): Dialog showing contact info about this ED
          },
          icon: const Icon(Icons.info_outline),
        ),
      ],
    );
  }
}
