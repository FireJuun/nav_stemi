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
              gapH32,
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
                        return FilledButton(
                          onPressed: () async {
                            final contactUri = Uri(
                              scheme: 'tel',
                              path: activeDestination
                                  .destinationInfo.facilityPhone1,
                            );
                            final canLaunch = await canLaunchUrl(contactUri);
                            if (canLaunch) {
                              debugPrint(
                                '''Calling ${activeDestination.destinationInfo.facilityBrandedName}: ${activeDestination.destinationInfo.facilityPhone1}''',
                              );
                              await launchUrl(contactUri);
                            } else {
                              debugPrint(
                                '''Cannot call ${activeDestination.destinationInfo.facilityBrandedName}''',
                              );
                            }
                          },
                          child: Text('Contact Destination'.hardcoded),
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
