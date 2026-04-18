import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
    final button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LavifyTheme.premiumPanelGradient(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isLight
              ? const Color(0x88D9C9B5)
              : LavifyTheme.borderColor(context),
        ),
        boxShadow: [
          ...LavifyTheme.panelShadow(context, floating: false),
          if (isLight)
            const BoxShadow(
              color: Color(0x12FFFFFF),
              blurRadius: 10,
              spreadRadius: -2,
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
                  colors: [Color(0x22FFFFFF), Color(0x00FFFFFF)],
                )
              : null,
        ),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.arrow_forward_rounded, size: 18),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          style: OutlinedButton.styleFrom(
            side: BorderSide.none,
            backgroundColor: Colors.transparent,
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
