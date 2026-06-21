import 'package:flutter/material.dart';

abstract class PwfWebHomeHtmlScreenBase extends StatefulWidget {
  final String unitSlug;
  final String? unitTitle;

  const PwfWebHomeHtmlScreenBase({
    super.key,
    this.unitSlug = 'home',
    this.unitTitle,
  });

  @override
  State<PwfWebHomeHtmlScreenBase> createState() =>
      _PwfWebHomeHtmlScreenBaseStubState();
}

class _PwfWebHomeHtmlScreenBaseStubState
    extends State<PwfWebHomeHtmlScreenBase> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
