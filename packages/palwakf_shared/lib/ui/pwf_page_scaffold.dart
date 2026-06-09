import 'package:flutter/material.dart';

/// Shared Scaffold wrapper that works on Web + Mobile.
///
/// It keeps RTL by default and provides fixed overlay slots.
class PwfPageScaffold extends StatelessWidget {
  const PwfPageScaffold({
    super.key,
    required this.child,
    this.floatingActionButton,
    this.header,
    this.footer,
    this.scrollController,
    this.backgroundColor,
  });

  final Widget child;
  final Widget? header;
  final Widget? footer;
  final Widget? floatingActionButton;
  final ScrollController? scrollController;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final controller = scrollController ?? ScrollController();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (n) {
              n.disallowIndicator();
              return true;
            },
            child: CustomScrollView(
              controller: controller,
              slivers: [
                if (header != null) SliverToBoxAdapter(child: header!),
                SliverToBoxAdapter(child: child),
                if (footer != null) SliverToBoxAdapter(child: footer!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
