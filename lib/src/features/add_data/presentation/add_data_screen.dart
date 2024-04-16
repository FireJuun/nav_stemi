import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  bool isSyncVisible = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Stack(
            children: [
              const AddDataScrollview(),
              if (!isKeyboardVisible)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: 300.ms,
                    height: isSyncVisible
                        ? MediaQuery.of(context).size.height * 0.25
                        : 0,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      border: isSyncVisible
                          ? Border.all(
                              color: colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    child: const Sync(),
                  ),
                ),
              if (!isKeyboardVisible)
                Positioned.directional(
                  textDirection: Directionality.of(context),
                  end: 4,
                  bottom: 4,
                  child: isSyncVisible
                      ? FilledButton.icon(
                          onPressed: () => setState(
                            () => isSyncVisible = false,
                          ),
                          icon: const Icon(Icons.sync),
                          label: Text('Sync'.hardcoded),
                        )
                      : FilledButton.tonalIcon(
                          style: Theme.of(context)
                              .filledButtonTheme
                              .style
                              ?.copyWith(
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    side: const BorderSide(),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                          onPressed: () => setState(
                            () => isSyncVisible = true,
                          ),
                          icon: const Icon(Icons.sync),
                          label: Text('Sync'.hardcoded),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class AddDataScrollview extends StatelessWidget {
  const AddDataScrollview({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        /// LayoutBuilder is used so that when the keyboard shows up,
        /// the app will automatically resize the checklist field.
        /// Otherwise, there's no space to see what you're typing.
        final checklistHeight = constraints.maxHeight * 0.3;
        return CustomScrollView(
          slivers: [
            const DestinationInfoSliver(),
            const SliverPinnedHeader(child: EtaWidget()),
            const SliverToBoxAdapter(child: gapH8),
            // gapH8,
            SliverToBoxAdapter(
              child: SizedBox(
                height: checklistHeight,
                child: const Checklist(),
              ),
            ),
            const SliverToBoxAdapter(child: gapH8),
            const SliverFillRemaining(
              child: AddDataTabs(),
            ),
          ],
        );
      },
    );
  }
}
