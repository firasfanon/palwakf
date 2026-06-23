import 'package:flutter/material.dart';

class UnitOperationalActivationPage extends StatelessWidget {
  final String unitId;

  const UnitOperationalActivationPage({super.key, required this.unitId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Unit Operational Activation')),
    );
  }
}
