import 'package:flutter/material.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

const _routeDurationDto = RouteDurationDto();

class EtaWidgetSliver extends StatelessWidget {
  const EtaWidgetSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverPinnedHeader(child: EtaWidget());
  }
}

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

        final routeDuration =
            Duration(seconds: navInfo.timeToFinalDestinationSeconds ?? 0);
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
