import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

class EtaWidget extends ConsumerWidget {
  const EtaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navInfoValue = ref.watch(navInfoProvider);

    return AsyncValueWidget<NavInfo?>(
      value: navInfoValue,
      data: (navInfo) {
        if (navInfo == null) {
          return const SizedBox();
        }

        final timeToDestination = navInfo.timeToFinalDestinationSeconds;

        /// Sometimes, a -1 value is provided, which is not valid.
        /// No need to show the ETA if the value is invalid.
        if (timeToDestination == null || timeToDestination < 0) {
          return const SizedBox();
        }

        final routeDuration = Duration(seconds: timeToDestination);
        final etaDateTime = DateTime.now().add(routeDuration);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
                '''${routeDuration.inMinutes.toString().padLeft(2, '0')}:${(routeDuration.inSeconds % 60).toString().padLeft(2, '0')}''',
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                TimeOfDay.fromDateTime(etaDateTime).format(context),
                textAlign: TextAlign.end,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.apply(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        );
      },
    );
  }
}
