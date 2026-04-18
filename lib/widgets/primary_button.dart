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
    final isEnabled = onPressed != null;

    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? const Color(0x88D8C7B2)
              : Colors.white.withAlpha(14),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEnabled
              ? [
                  isLight
                      ? LavifyColors.lightNavy
                      : LavifyColors.primaryStrong,
                  isLight ? const Color(0xFF4A6082) : LavifyColors.accent,
                ]
              : [
                  isLight ? const Color(0xFFB9B1A7) : const Color(0xFF2F3A4D),
                  isLight ? const Color(0xFFD1C7BB) : const Color(0xFF445066),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isLight ? const Color(0x20314664) : const Color(0x306AA8FF),
            blurRadius: isLight ? 26 : 34,
            offset: Offset(0, isLight ? 12 : 18),
          ),
          if (isLight)
            const BoxShadow(
              color: Color(0x12FFFDF9),
              blurRadius: 10,
              spreadRadius: -2,
              offset: Offset(0, -1),
            ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isLight
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
                )
              : null,
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.water_drop_rounded, size: 18),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: isEnabled ? Colors.white : Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
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
