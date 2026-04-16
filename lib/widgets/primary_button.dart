import 'package:flutter/material.dart';

import '../theme/theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon ?? Icons.water_drop_rounded, size: 18);
    final labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final isEnabled = onPressed != null;

    final button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnabled
              ? [LavifyColors.primaryStrong, LavifyColors.primary]
              : [Color(0xFF3C4A63), Color(0xFF55627A)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3322C1FF),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: RepaintBoundary(
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: iconWidget,
          label: labelWidget,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: isEnabled
                ? Colors.white
                : Colors.white.withAlpha(180),
          ),
        ),
      ),
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
