import 'package:flutter/material.dart';

class PwfComplaintsTabScaffold extends StatelessWidget {
  final List<String> tabs;
  final List<Widget> children;

  const PwfComplaintsTabScaffold({
    super.key,
    required this.tabs,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 640;
        return DefaultTabController(
          length: tabs.length,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7ECF2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE5EAF0)),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [Color(0xFFF9FBFD), Color(0xFFF4F7FB)],
                    ),
                  ),
                  child: TabBar(
                    isScrollable: true,
                    indicatorColor: const Color(0xFFD4AF37),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF0B3A6A),
                    unselectedLabelColor: const Color(0xFF667085),
                    labelStyle: TextStyle(
                      fontSize: mobile ? 13 : 15,
                      fontWeight: FontWeight.w800,
                    ),
                    tabs: [
                      for (final t in tabs)
                        Tab(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: mobile ? 6 : 10,
                            ),
                            child: Text(
                              t,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(child: TabBarView(children: children)),
              ],
            ),
          ),
        );
      },
    );
  }
}
