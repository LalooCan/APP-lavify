import 'package:flutter/material.dart';

import '../theme/theme.dart';

class WorkerJobsPage extends StatelessWidget {
  const WorkerJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Servicios',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  'Revisa tus servicios asignados, en progreso y completados.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                const _JobStatusCard(
                  title: 'En camino',
                  client: 'Cliente · Av. Reforma 245',
                  packageLabel: 'Full Care · Sedan mediano',
                  accent: LavifyColors.primary,
                ),
                const SizedBox(height: 14),
                const _JobStatusCard(
                  title: 'Pendiente',
                  client: 'Cliente · Polanco 320',
                  packageLabel: 'Express · SUV',
                  accent: Color(0xFFFFC857),
                ),
                const SizedBox(height: 14),
                const _JobStatusCard(
                  title: 'Completado',
                  client: 'Cliente · Del Valle 120',
                  packageLabel: 'Premium · Compacto',
                  accent: LavifyColors.success,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JobStatusCard extends StatelessWidget {
  const _JobStatusCard({
    required this.title,
    required this.client,
    required this.packageLabel,
    required this.accent,
  });

  final String title;
  final String client;
  final String packageLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accent.withAlpha(28),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LavifyColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  packageLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: LavifyColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
