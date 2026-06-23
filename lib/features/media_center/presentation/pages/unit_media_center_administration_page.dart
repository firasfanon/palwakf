import 'package:flutter/material.dart';

class UnitMediaCenterAdministrationPage extends StatelessWidget {
  final String? initialSectionKey;

  const UnitMediaCenterAdministrationPage({
    super.key,
    this.initialSectionKey,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Unit Media Center Administration'),
      ),
    );
  }
}
