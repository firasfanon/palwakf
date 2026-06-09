import 'package:flutter/material.dart';

import 'widgets/sections/unit_pages_management_section.dart';

class UnitPagesExecutionScreen extends StatelessWidget {
  const UnitPagesExecutionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: null,
        body: Padding(
          padding: EdgeInsets.all(12),
          child: PwfUnitPagesManagementSection(),
        ),
      ),
    );
  }
}
