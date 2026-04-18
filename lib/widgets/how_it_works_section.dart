import 'package:flutter/material.dart';

import '../theme/theme.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    const items = [
      _HowItWorksItemData(
        step: '01',
        title: 'Elige paquete',
        description:
            'Selecciona Express, Full Care o Premium segun el tiempo y acabado que quieras.',
        icon: Icons.local_car_wash_rounded,
      ),
      _HowItWorksItemData(
        step: '02',
        title: 'Confirma ubicacion',
        description:
            'Marca el punto exacto del servicio y deja listo el pedido para backend.',
        icon: Icons.location_on_rounded,
      ),
      _HowItWorksItemData(
        step: '03',
        title: 'Llega el lavador',
        description:
            'Un profesional verificado llega a tu zona con seguimiento en tiempo real.',
        icon: Icons.directions_car_filled_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como funciona',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Un flujo simple para pedir tu lavado como si fuera una app on-demand.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontSize: isCompact ? 15 : 16),
        ),
        SizedBox(height: isCompact ? 12 : 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final spacing = isCompact ? 10.0 : 14.0;
            final columns = isCompact ? 2 : availableWidth >= 920 ? 3 : 2;
            final cardWidth =
                (availableWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: items
                  .map(
                    (item) => _HowItWorksCard(
                      item: item,
                      width: cardWidth,
                      isCompact: isCompact,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({
    required this.item,
    required this.width,
    required this.isCompact,
  });

  final _HowItWorksItemData item;
  final double width;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);
    final radius = BorderRadius.circular(isCompact ? 20 : 24);

    return RepaintBoundary(
      child: Container(
        width: width,
        padding: EdgeInsets.all(isCompact ? 14 : 18),
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLight
                ? const [Color(0xFFFFFCF8), Color(0xFFF3ECE4)]
                : const [
                    Color(0xCC12203A),
                    Color(0xCC0C1527),
                  ],
          ),
          border: Border.all(
            color: isLight
                ? const Color(0x88D9C9B5)
                : LavifyColors.primary.withAlpha(34),
          ),
          boxShadow: [
            BoxShadow(
              color: isLight
                  ? const Color(0x181D2432)
                  : Colors.black.withAlpha(28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: isCompact ? 34 : 40,
                  height: isCompact ? 34 : 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
                    color: isLight
                        ? const Color(0xFFFDF8F1)
                        : Colors.white.withAlpha(6),
                    border: Border.all(
                      color: isLight
                          ? const Color(0x77D8C8B4)
                          : LavifyColors.primary.withAlpha(18),
                    ),
                  ),
                  child: Text(
                    item.step,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isLight
                          ? LavifyColors.lightNavy
                          : LavifyColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: isCompact ? 13 : null,
                    ),
                  ),
                ),
                SizedBox(width: isCompact ? 10 : 12),
                Container(
                  width: isCompact ? 34 : 40,
                  height: isCompact ? 34 : 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isLight
                            ? const Color(0x22D6B47B)
                            : LavifyColors.primary.withAlpha(34),
                        isLight ? Colors.white : Colors.white.withAlpha(8),
                      ],
                    ),
                    border: Border.all(
                      color: isLight
                          ? const Color(0x77D8C8B4)
                          : LavifyColors.primary.withAlpha(32),
                    ),
                  ),
                  child: Icon(
                    item.icon,
                    color: isLight
                        ? LavifyColors.lightNavy
                        : LavifyColors.primary,
                    size: isCompact ? 18 : 22,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 12 : 14),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isCompact ? 16 : 18,
                height: 1.05,
                color: isLight
                    ? LavifyColors.lightTextPrimary
                    : LavifyColors.textPrimary,
              ),
            ),
            SizedBox(height: isCompact ? 6 : 8),
            Text(
              item.description,
              maxLines: isCompact ? 4 : 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: isCompact ? 12.5 : 13,
                height: 1.35,
                color: isLight
                    ? LavifyColors.lightTextSecondary
                    : Colors.white.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksItemData {
  const _HowItWorksItemData({
    required this.step,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String step;
  final String title;
  final String description;
  final IconData icon;
}
