import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class PatientInfo extends StatelessWidget {
  const PatientInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // final state = ref.

    return SliverMainAxisGroup(
      slivers: [
        // DataEntryHeader('Patient Info'.hardcoded),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        label: Text('Last Name'),
                      ),
                      onTapOutside: (PointerDownEvent event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                  gapW16,
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        label: Text('First Name'),
                      ),
                      onTapOutside: (PointerDownEvent event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                ],
              ),
              gapH24,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        label: Text('Date of Birth'),
                      ),
                      onTapOutside: (PointerDownEvent event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Age: 42',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              gapH24,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        label: Text('Gender'),
                      ),
                      onTapOutside: (PointerDownEvent event) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Male',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        showDialog<bool>(
                          context: context,
                          builder: (context) => const ScanQrLicenseDialog(),
                        );
                      },
                      child: Text('Scan'.hardcoded),
                    ),
                  ),
                ],
              ),
              gapH24,
              TextField(
                decoration: const InputDecoration(
                  label: Text('Cardiologist'),
                ),
                onTapOutside: (PointerDownEvent event) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
              gapH48,
            ],
          ),
        ),
      ],
    );
  }
}
