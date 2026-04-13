import 'package:flutter/material.dart';

import '../theme/theme.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: items.map((item) => _HowItWorksCard(item: item)).toList(),
        ),
      ],
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard({required this.item});

  final _HowItWorksItemData item;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LavifyColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: LavifyColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white.withAlpha(10),
                  ),
                  child: Text(
                    item.step,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LavifyColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0x1A22C1FF),
                  ),
                  child: Icon(item.icon, color: LavifyColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: Theme.of(context).textTheme.bodyMedium,
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
