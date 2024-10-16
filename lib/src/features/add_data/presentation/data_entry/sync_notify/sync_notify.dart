import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

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
              gapH24,
              Column(
                children: [
                  Text('Contact ED / Cath lab'.hardcoded),
                  gapH12,
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () {
                          // TODO(FireJuun): Implement ED or Cath Lab call/contact functionality
                        },
                        child: Text('Call Cath Lab'.hardcoded),
                      ),
                      gapW12,
                      OutlinedButton(
                        onPressed: () {
                          // TODO(FireJuun): Implement ED or Cath Lab call/contact functionality
                        },
                        child: Text('Call Nearest ED'.hardcoded),
                      ),
                    ],
                  ),
                ],
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
    return Row(
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
                child: Text('Scan Session'.hardcoded),
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
    );
  }
}
