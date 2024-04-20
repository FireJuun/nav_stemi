import 'package:flutter/material.dart';
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
    final availableRoutesValue = ref.watch(availableRoutesProvider);

    return AsyncValueWidget<AvailableRoutes?>(
      value: availableRoutesValue,
      data: (availableRoutes) {
        final activeRouteValue = ref.watch(activeRouteProvider);

        return AsyncValueWidget<ActiveRoute?>(
          value: activeRouteValue,
          data: (activeRoute) {
            // if (activeRoute == null || availableRoutes == null) {
            //   throw RouteInformationNotAvailableException();
            // }

            // TODO(FireJuun): Adjust ETA after multiple navigation steps (or refresh time on occasion)

            final routeDuration = _routeDurationDto
                    .routeDurationToSeconds(activeRoute?.route.duration) ??
                Duration.zero;
            final durationFromRequested =
                availableRoutes?.requestedDateTime.add(routeDuration);
            final durationMin = _routeDurationDto
                .routeDurationToMinsString(activeRoute?.route.duration);

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
                    durationMin,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    durationFromRequested == null
                        ? '--'
                        : TimeOfDay.fromDateTime(durationFromRequested)
                            .format(context),
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
      },
    );
  }
}
