import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../theme/theme.dart';
import 'primary_button.dart';

class PackageCard extends StatelessWidget {
  const PackageCard({
    super.key,
    required this.package,
    required this.onPressed,
  });

  final WashPackage package;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LavifyColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: LavifyColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white.withAlpha(10),
              ),
              child: Icon(package.icon, color: LavifyColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              package.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              package.formattedPrice,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: LavifyColors.primary,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              package.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Pedir este',
              onPressed: onPressed,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}
