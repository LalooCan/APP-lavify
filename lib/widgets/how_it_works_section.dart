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
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: isCompact ? 16 : 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final cardWidth = isCompact
                ? availableWidth
                : (availableWidth >= 920 ? (availableWidth - 32) / 3 : 280.0);

            return Wrap(
              spacing: isCompact ? 12 : 16,
              runSpacing: isCompact ? 12 : 16,
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
    return RepaintBoundary(
      child: Container(
        width: width,
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: LavifyTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
          border: Border.all(color: LavifyTheme.borderColor(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: isCompact ? 38 : 42,
                  height: isCompact ? 38 : 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
                    color: LavifyTheme.softFillColor(context),
                  ),
                  child: Text(
                    item.step,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LavifyColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: isCompact ? 13 : null,
                    ),
                  ),
                ),
                SizedBox(width: isCompact ? 10 : 12),
                Container(
                  width: isCompact ? 38 : 42,
                  height: isCompact ? 38 : 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
                    color: const Color(0x1A22C1FF),
                  ),
                  child: Icon(
                    item.icon,
                    color: LavifyColors.primary,
                    size: isCompact ? 20 : 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: isCompact ? 12 : 16),
            Text(
              item.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: isCompact ? 18 : null),
            ),
            SizedBox(height: isCompact ? 6 : 8),
            Text(
              item.description,
              maxLines: isCompact ? 3 : null,
              overflow: isCompact ? TextOverflow.ellipsis : null,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: isCompact ? 14 : null),
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
