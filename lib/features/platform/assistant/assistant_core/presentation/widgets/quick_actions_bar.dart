import 'package:flutter/material.dart';

import '../../data/models/quick_action_item.dart';
import '../theme/chat_palette.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({
    super.key,
    required this.actions,
    required this.onTap,
  });

  final List<QuickActionItem> actions;
  final void Function(QuickActionItem action) onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions.map((action) {
        return _QuickActionChip(action: action, onTap: () => onTap(action));
      }).toList(),
    );
  }
}

class _QuickActionChip extends StatefulWidget {
  const _QuickActionChip({required this.action, required this.onTap});

  final QuickActionItem action;
  final VoidCallback onTap;

  @override
  State<_QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<_QuickActionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final border = ChatPalette.borderFor(context);
    final bg = _hovered ? ChatPalette.primary : ChatPalette.panelFor(context);
    final fg = _hovered
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: widget.onTap,
          customBorder: const StadiumBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: ShapeDecoration(
              shape: StadiumBorder(
                side: BorderSide(
                  color: _hovered ? ChatPalette.primary : border,
                ),
              ),
              color: bg,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.action.icon, size: 16, color: fg),
                const SizedBox(width: 8),
                Text(
                  widget.action.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
