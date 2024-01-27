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
      child: Column(
        children: [
          DestinationInfo(),
          gapH12,
          EtaWidget(),
          gapH8,
          Expanded(
            child: DataEntryWidget(),
          ),
        ],
      ),
    );
  }
}
