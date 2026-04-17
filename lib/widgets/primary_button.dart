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
    final isLight = LavifyTheme.isLight(context);
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
              ? [
                  isLight
                      ? const Color(0xFF4D8DFF)
                      : LavifyColors.primaryStrong,
                  isLight ? const Color(0xFF56C7FA) : LavifyColors.primary,
                ]
              : [
                  isLight ? const Color(0xFFB7C3D4) : const Color(0xFF3C4A63),
                  isLight ? const Color(0xFFC4CEDC) : const Color(0xFF55627A),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x203478F6) : const Color(0x2A5AC8FA),
            blurRadius: 28,
            offset: const Offset(0, 14),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
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
