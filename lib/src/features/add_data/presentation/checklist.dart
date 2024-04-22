import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

class Checklist extends StatelessWidget {
  const Checklist({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: CustomScrollView(
        slivers: [
          SliverPinnedHeader(
            child: Container(
              color: colorScheme.secondary,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                child: Text(
                  'Checklist'.hardcoded,
                  style: textTheme.bodyLarge
                      ?.apply(color: colorScheme.onSecondary),
                ),
              ),
            ),
          ),
          SliverCrossAxisGroup(
            slivers: [
              SliverCrossAxisExpanded(
                flex: 1,
                sliver: SliverList.list(
                  children: [
                    ChecklistItem(label: 'EKG by 5 min'.hardcoded),
                    ChecklistItem(label: 'Give Aspirin 325'.hardcoded),
                    ChecklistItem(label: 'Leave by 10 min'.hardcoded),
                  ],
                ),
              ),
              SliverCrossAxisExpanded(
                flex: 1,
                sliver: SliverList.list(
                  children: [
                    ChecklistItem(label: 'Pt Info'.hardcoded),
                    ChecklistItem(label: 'Pt Cardiologist'.hardcoded),
                    ChecklistItem(label: 'Notify Cath Lab'.hardcoded),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChecklistItem extends StatefulWidget {
  const ChecklistItem({required this.label, super.key});

  final String label;

  @override
  State<ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<ChecklistItem> {
  bool? isSelected = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CheckboxListTile(
      value: isSelected,
      tristate: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2),
      visualDensity: VisualDensity.compact,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (newValue) {
        setState(() {
          isSelected = newValue;
        });
      },
      title: Text(
        widget.label,
        style: textTheme.bodySmall?.apply(
          decoration: switch (isSelected) {
            true => TextDecoration.lineThrough,
            false => null,
            null => TextDecoration.lineThrough,
          },
          color: switch (isSelected) {
            true => colorScheme.outline,
            false => colorScheme.onBackground,
            null => colorScheme.error,
          },
        ),
      ),
    );
  }
}
