import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class AddDataScreen extends StatelessWidget {
  const AddDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: AddDataScrollview(),
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
        return Column(
          children: [
            const Expanded(
              child: CustomScrollView(
                slivers: [
                  DestinationInfoSliver(),
                  EtaWidgetSliver(),
                  SliverToBoxAdapter(child: gapH8),
                  SliverToBoxAdapter(
                    child: Divider(thickness: 2),
                  ),
                  SliverFillRemaining(
                    child: AddDataTabs(),
                  ),
                ],
              ),
            ),
            gapH8,
            SizedBox(
              height: checklistHeight,
              child: const Checklist(),
            ),
          ],
        );
      },
    );
  }
}
