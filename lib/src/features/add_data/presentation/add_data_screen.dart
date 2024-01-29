import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:nav_stemi/nav_stemi.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  bool _showChecklist = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        final colorScheme = Theme.of(context).colorScheme;
        bool shouldShowChecklist() => _showChecklist && !isKeyboardVisible;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const DestinationInfo(),
                  gapH4,
                  const EtaWidget(),
                  gapH8,
                  const Expanded(
                    child: DataEntryWidget(),
                  ),
                  AnimatedContainer(
                    duration: 300.ms,
                    height: shouldShowChecklist() ? 0 : 60,
                    child: const SizedBox.shrink(),
                  ),
                  AnimatedContainer(
                    duration: 300.ms,
                    height: shouldShowChecklist()
                        ? MediaQuery.of(context).size.height * 0.25
                        : 0,
                    // TODO(FireJuun): checklist goes here
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      border: shouldShowChecklist()
                          ? Border.all(
                              color: colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    child: const Center(child: Text('Checklist')),
                  ),
                ],
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: 4,
                bottom: 4,
                child: AnimatedSwitcher(
                  duration: 300.ms,
                  child: shouldShowChecklist()
                      ? FilledButton(
                          onPressed: () =>
                              setState(() => _showChecklist = false),
                          child: Text('Checklist'.hardcoded),
                        )
                      : OutlinedButton(
                          onPressed: () =>
                              setState(() => _showChecklist = true),
                          child: Text('Checklist'.hardcoded),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
