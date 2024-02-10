import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

class DataEntryWidget extends StatelessWidget {
  const DataEntryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        TimeMetrics(),
        PatientInfo(),
        CareTeam(),
      ],
    );
  }
}
