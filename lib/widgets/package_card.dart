import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../theme/theme.dart';

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
    final isPopular = package.name == 'Full Care';
    final radius = BorderRadius.circular(isCompact ? 22 : 26);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.92, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 22),
            child: Transform.scale(scale: value, child: child),
          ),
        );
      },
      child: RepaintBoundary(
        child: SizedBox(
          width: isCompact ? double.infinity : 260,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      LavifyColors.primary.withAlpha(isPopular ? 130 : 95),
                      Colors.white.withAlpha(28),
                      LavifyColors.primaryStrong.withAlpha(
                        isPopular ? 100 : 60,
                      ),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 22,
                      offset: const Offset(0, 14),
                    ),
                    BoxShadow(
                      color: LavifyColors.primary.withAlpha(
                        isPopular ? 40 : 18,
                      ),
                      blurRadius: isPopular ? 24 : 18,
                      spreadRadius: isPopular ? 1 : 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(1.2),
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    isCompact ? 14 : 16,
                    isCompact ? 14 : 16,
                    isCompact ? 14 : 16,
                    isCompact ? 13 : 15,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: radius.subtract(
                      const BorderRadius.all(Radius.circular(1.2)),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xDD13213A), Color(0xCC0D1528)],
                    ),
                    border: Border.all(color: Colors.white.withAlpha(18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: isCompact ? 38 : 42,
                            height: isCompact ? 38 : 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                isCompact ? 12 : 14,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  LavifyColors.primary.withAlpha(36),
                                  Colors.white.withAlpha(10),
                                ],
                              ),
                              border: Border.all(
                                color: LavifyColors.primary.withAlpha(45),
                              ),
                            ),
                            child: Icon(
                              package.icon,
                              color: LavifyColors.primary,
                              size: isCompact ? 18 : 22,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isCompact ? 9 : 10,
                              vertical: isCompact ? 5 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(8),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: LavifyColors.primary.withAlpha(52),
                              ),
                            ),
                            child: Text(
                              package.priceLabel,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: LavifyColors.primary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 12 : 14),
                      Text(
                        package.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: isCompact ? 18 : 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: isCompact ? 8 : 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              package.formattedPrice,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: isCompact ? 33 : 36,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.1,
                                    height: 0.95,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: onPressed,
                            style: FilledButton.styleFrom(
                              backgroundColor: LavifyColors.primaryStrong,
                              foregroundColor: Colors.white,
                              minimumSize: Size(0, isCompact ? 36 : 38),
                              padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 14 : 16,
                                vertical: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: TextStyle(
                                fontSize: isCompact ? 13 : 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: const Text('Pedir'),
                          ),
                        ],
                      ),
                      SizedBox(height: isCompact ? 8 : 10),
                      Text(
                        package.description,
                        maxLines: isCompact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: isCompact ? 12.5 : 13,
                          height: 1.35,
                          color: Colors.white.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isPopular)
                Positioned(
                  top: -10,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7FE4FF), Color(0xFF4F8DFF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: LavifyColors.primary.withAlpha(60),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Text(
                      'MAS POPULAR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF081120),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
