import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:url_launcher/url_launcher.dart';

class SyncNotify extends ConsumerWidget {
  const SyncNotify({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList.list(
            children: [
              const SyncNotifyShareSession(),
              gapH8,
              Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    final destinationValue =
                        ref.watch(activeDestinationProvider);

                    return AsyncValueWidget<ActiveDestination?>(
                      value: destinationValue,
                      data: (activeDestination) {
                        if (activeDestination == null) {
                          return Text('--'.hardcoded);
                        }

                        final edDestinationInfo =
                            activeDestination.destinationInfo;

                        return Column(
                          children: [
                            const Divider(thickness: 2),
                            Text(
                              'Contact Destination'.hardcoded,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const Divider(thickness: 2),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 32,
                              children: [
                                DestinationPhoneItem(
                                  phoneNumber: edDestinationInfo.facilityPhone1,
                                  phoneNote:
                                      edDestinationInfo.facilityPhone1Note,
                                ),
                                if (edDestinationInfo.facilityPhone2 != null)
                                  DestinationPhoneItem(
                                    phoneNumber:
                                        edDestinationInfo.facilityPhone2!,
                                    phoneNote:
                                        edDestinationInfo.facilityPhone2Note,
                                  ),
                                if (edDestinationInfo.facilityPhone3 != null)
                                  DestinationPhoneItem(
                                    phoneNumber:
                                        edDestinationInfo.facilityPhone3!,
                                    phoneNote:
                                        edDestinationInfo.facilityPhone3Note,
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SyncNotifyShareSession extends StatelessWidget {
  const SyncNotifyShareSession({this.usePrimaryColor = false, super.key});

  final bool usePrimaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  'Sync this session with others:'.hardcoded,
                  textAlign: TextAlign.center,
                ),
                gapH12,
                FilledButton(
                  onPressed: () {
                    // TODO(FireJuun): Add QR scan functionality
                  },
                  child: Text(
                    'Scan Session'.hardcoded,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Image.asset(
              usePrimaryColor
                  ? 'assets/placeholder_share_qr_primary.png'
                  : 'assets/placeholder_share_qr.png',
              width: 150,
              height: 150,
            ),
          ),
        ],
      ),
    );
  }
}
