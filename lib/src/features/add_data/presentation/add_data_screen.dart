import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

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
            const DestinationInfo(),
            const EtaWidget(),
            const Divider(thickness: 2),
            const Expanded(child: AddDataTabs()),
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
