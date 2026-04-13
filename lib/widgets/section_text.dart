import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SectionText extends StatelessWidget {
  const SectionText({
    super.key,
    required this.title,
    this.highlight,
    required this.subtitle,
    this.alignment = CrossAxisAlignment.start,
  });

  final String title;
  final String? highlight;
  final String subtitle;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(title, style: textTheme.headlineLarge),
        if (highlight != null) ...[
          const SizedBox(height: 8),
          Text(
            highlight!,
            style: textTheme.headlineLarge?.copyWith(
              color: LavifyColors.primary,
            ),
          ),
        ],
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Text(subtitle, style: textTheme.bodyLarge),
        ),
      ],
    );
  }
}
