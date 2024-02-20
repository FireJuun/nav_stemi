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
                    ChecklistItem(label: 'Give aspirin 325'.hardcoded),
                    ChecklistItem(label: 'Leave by 10 min'.hardcoded),
                  ],
                ),
              ),
              SliverCrossAxisExpanded(
                flex: 1,
                sliver: SliverList.list(
                  children: [
                    ChecklistItem(label: 'Name (last, first)'.hardcoded),
                    ChecklistItem(label: 'Cardiologist'.hardcoded),
                    ChecklistItem(label: 'Notify cath lab'.hardcoded),
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
    final selected = isSelected ?? false;

    return CheckboxListTile(
      value: isSelected,
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
          decoration: selected ? TextDecoration.lineThrough : null,
          color: selected ? colorScheme.outline : colorScheme.onBackground,
        ),
      ),
    );
  }
}
