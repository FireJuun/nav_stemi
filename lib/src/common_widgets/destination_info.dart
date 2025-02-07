import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

class DestinationInfoSliver extends StatelessWidget {
  const DestinationInfoSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverPinnedHeader(child: DestinationInfo());
  }
}

class DestinationInfo extends ConsumerWidget {
  const DestinationInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDesinationValue = ref.watch(activeDestinationProvider);
    return AsyncValueWidget<ActiveDestination?>(
      value: activeDesinationValue,
      data: (activeDestination) {
        if (activeDestination == null) {
          return const SizedBox();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Destination:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: Text(
                activeDestination.destinationInfo.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(goRouterProvider).goNamed(
                      AppRoute.navInfo.name,
                      extra: activeDestination.destinationInfo,
                    );
              },
              icon: const Icon(Icons.info_outline),
            ),
          ],
        );
      },
    );
  }
}

class DestinationInfoDialog extends StatelessWidget {
  const DestinationInfoDialog(this.edDestinationInfo, {super.key});

  final Hospital edDestinationInfo;

  @override
  Widget build(BuildContext context) {
    return ResponsiveDialogWidget(
      denseHeight: true,
      child: Column(
        children: [
          ResponsiveDialogHeader(label: 'Destination Info'.hardcoded),
          Expanded(
            child: ListView(
              children: [
                Center(
                  child: Text(
                    edDestinationInfo.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                gapH24,
                Text(
                  edDestinationInfo.address,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  edDestinationInfo.telephone,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                gapH24,
                Text(
                  edDestinationInfo.website,
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ResponsiveDialogFooter(label: 'Close'.hardcoded),
        ],
      ),
    );
  }
}
