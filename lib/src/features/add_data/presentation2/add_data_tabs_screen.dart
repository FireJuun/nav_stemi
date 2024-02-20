import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

class AddDataTabsScreen extends StatefulWidget {
  const AddDataTabsScreen({super.key});

  @override
  State<AddDataTabsScreen> createState() => _AddDataTabsScreenState();
}

class _AddDataTabsScreenState extends State<AddDataTabsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          /// LayoutBuilder is used so that when the keyboard shows up,
          /// the app will automatically resize the checklist field.
          /// Otherwise, there's no space to see what you're typing.
          final checklistHeight = constraints.maxHeight * 0.3;
          return CustomScrollView(
            slivers: [
              const SliverPinnedHeader(child: DestinationInfo()),
              const SliverPinnedHeader(child: EtaWidget()),
              // gapH8,
              SliverToBoxAdapter(
                child: SizedBox(
                  height: checklistHeight,
                  child: const Checklist(),
                ),
              ),
              const SliverFillRemaining(
                child: DataEntryTabs(),
              ),
            ],
          );
        },
      ),
    );
  }
}
