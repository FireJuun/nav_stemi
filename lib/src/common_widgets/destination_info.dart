import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

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
                activeDestination.destinationInfo.facilityBrandedName,
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
                    edDestinationInfo.facilityBrandedName,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                gapH24,
                Text(
                  edDestinationInfo.facilityAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  '''${edDestinationInfo.facilityCity}, ${edDestinationInfo.facilityState} ${edDestinationInfo.facilityZip}''',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                /// Dynamically show 1-3 phone numbers
                /// based on data available for each site
                DestinationPhoneItem(
                  phoneNumber: edDestinationInfo.facilityPhone1,
                  phoneNote: edDestinationInfo.facilityPhone1Note,
                ),
                if (edDestinationInfo.facilityPhone2 != null)
                  DestinationPhoneItem(
                    phoneNumber: edDestinationInfo.facilityPhone2!,
                    phoneNote: edDestinationInfo.facilityPhone2Note,
                  ),
                if (edDestinationInfo.facilityPhone3 != null)
                  DestinationPhoneItem(
                    phoneNumber: edDestinationInfo.facilityPhone3!,
                    phoneNote: edDestinationInfo.facilityPhone3Note,
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

class DestinationPhoneItem extends StatelessWidget {
  const DestinationPhoneItem({
    required this.phoneNumber,
    required this.phoneNote,
    super.key,
  });

  final String phoneNumber;
  final String? phoneNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        gapH16,
        GestureDetector(
          onTap: () async => callDestination(phoneNumber),
          child: Text(
            phoneNumber,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.apply(decoration: TextDecoration.underline),
            textAlign: TextAlign.center,
          ),
        ),
        if (phoneNote != null)
          Text(
            phoneNote!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
