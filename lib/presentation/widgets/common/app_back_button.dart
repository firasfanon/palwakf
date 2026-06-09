import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBackButton extends StatelessWidget {
  final String fallbackLocation;
  final String? tooltip;

  const AppBackButton({
    super.key,
    this.fallbackLocation = '/home',
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip ?? 'رجوع',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // GoRouter safe back
        if (GoRouter.of(context).canPop()) {
          context.pop();
        } else {
          context.go(fallbackLocation);
        }
      },
    );
  }
}
