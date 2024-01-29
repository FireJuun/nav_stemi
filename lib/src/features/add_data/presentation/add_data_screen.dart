import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:nav_stemi/nav_stemi.dart';

enum BottomModalState { checklist, sync, none }

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  BottomModalState _bottomModalState = BottomModalState.none;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        final colorScheme = Theme.of(context).colorScheme;

        bool showBottomModal() =>
            _bottomModalState != BottomModalState.none && !isKeyboardVisible;

        bool isChecklistActive() =>
            _bottomModalState == BottomModalState.checklist;

        bool isSyncActive() => _bottomModalState == BottomModalState.sync;

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
                    height: showBottomModal() ? 0 : 60,
                    child: const SizedBox.shrink(),
                  ),
                  AnimatedContainer(
                    duration: 300.ms,
                    height: showBottomModal()
                        ? MediaQuery.of(context).size.height * 0.25
                        : 0,
                    // TODO(FireJuun): checklist goes here
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      border: showBottomModal()
                          ? Border.all(
                              color: colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    child: switch (_bottomModalState) {
                      BottomModalState.checklist =>
                        Center(child: Text('Checklist'.hardcoded)),
                      BottomModalState.sync =>
                        Center(child: Text('Sync'.hardcoded)),
                      BottomModalState.none =>
                        const Center(child: SizedBox.shrink()),
                    },
                  ),
                ],
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: 4,
                bottom: 4,
                child: AnimatedSwitcher(
                  duration: 300.ms,
                  child: _bottomModalState == BottomModalState.checklist
                      ? FilledButton.icon(
                          onPressed: () => setState(
                            () => _bottomModalState = BottomModalState.none,
                          ),
                          icon: const Icon(Icons.checklist),
                          label: Text('Checklist'.hardcoded),
                        )
                      : OutlinedButton.icon(
                          onPressed: isSyncActive()
                              ? null
                              : () => setState(
                                    () => _bottomModalState =
                                        BottomModalState.checklist,
                                  ),
                          icon: const Icon(Icons.checklist),
                          label: Text('Checklist'.hardcoded),
                        ),
                ),
              )
                  .animate(
                    target: isSyncActive() ? 1 : 0,
                  )
                  .fadeOut(duration: 200.ms),
              Positioned.directional(
                textDirection: Directionality.of(context),
                start: 4,
                bottom: 4,
                child: _bottomModalState == BottomModalState.sync
                    ? FilledButton.icon(
                        onPressed: () => setState(
                          () => _bottomModalState = BottomModalState.none,
                        ),
                        icon: const Icon(Icons.sync),
                        label: Text('Sync'.hardcoded),
                      )
                    : OutlinedButton.icon(
                        onPressed: isChecklistActive()
                            ? null
                            : () => setState(
                                  () =>
                                      _bottomModalState = BottomModalState.sync,
                                ),
                        icon: const Icon(Icons.sync),
                        label: Text('Sync'.hardcoded),
                      ),
              )
                  .animate(
                    target: isChecklistActive() ? 1 : 0,
                  )
                  .fadeOut(duration: 200.ms),
            ],
          ),
        );
      },
    );
  }
}
