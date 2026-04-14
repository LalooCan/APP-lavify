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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return RepaintBoundary(
      child: Container(
        width: isCompact ? double.infinity : 260,
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: LavifyTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(isCompact ? 22 : 26),
          border: Border.all(color: LavifyTheme.borderColor(context)),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: isCompact ? 40 : 44,
                  height: isCompact ? 40 : 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
                    color: LavifyTheme.softFillColor(context),
                  ),
                  child: Icon(
                    package.icon,
                    color: LavifyColors.primary,
                    size: isCompact ? 20 : 24,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 10 : 12,
                    vertical: isCompact ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x1422C1FF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: LavifyColors.primary.withAlpha(70),
                    ),
                  ),
                  child: Text(
                    package.priceLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: LavifyColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 14 : 16),
            Text(
              package.name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: isCompact ? 18 : null),
            ),
            SizedBox(height: isCompact ? 4 : 6),
            Text(
              package.formattedPrice,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: LavifyColors.primary,
                fontSize: isCompact ? 22 : null,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: isCompact ? 8 : 10),
            Text(
              package.description,
              maxLines: isCompact ? 3 : null,
              overflow: isCompact ? TextOverflow.ellipsis : null,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: isCompact ? 14 : null),
            ),
            SizedBox(height: isCompact ? 14 : 18),
            SizedBox(
              height: isCompact ? 44 : null,
              child: PrimaryButton(
                label: isCompact ? 'Pedir' : 'Pedir este',
                onPressed: onPressed,
                isExpanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
