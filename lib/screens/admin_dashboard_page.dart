import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../theme/theme.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Panel de administrador',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _OrderStatsSection(),
                      SizedBox(height: 28),
                      _PendingVerificationsSection(),
                      SizedBox(height: 28),
                      _RecentOrdersSection(),
                    ],
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

class _OrderStatsSection extends StatelessWidget {
  const _OrderStatsSection();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final all = docs.map((d) {
          try {
            return WashOrder.fromMap({...d.data(), 'id': d.id});
          } catch (_) {
            return null;
          }
        }).whereType<WashOrder>().toList();

        final active = all
            .where((o) =>
                o.status != OrderStatus.completed &&
                o.status != OrderStatus.cancelled)
            .length;
        final completed =
            all.where((o) => o.status == OrderStatus.completed).length;
        final cancelled =
            all.where((o) => o.status == OrderStatus.cancelled).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Órdenes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatChip(label: 'Total', value: '${all.length}'),
                _StatChip(
                  label: 'Activas',
                  value: '$active',
                  color: LavifyColors.primary,
                ),
                _StatChip(
                  label: 'Completadas',
                  value: '$completed',
                  color: LavifyColors.success,
                ),
                _StatChip(
                  label: 'Canceladas',
                  value: '$cancelled',
                  color: const Color(0xFFFF6B6B),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PendingVerificationsSection extends StatelessWidget {
  const _PendingVerificationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verificaciones pendientes',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('profiles')
              .where('verificationStatus', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Text(
                'No hay solicitudes pendientes.',
                style: Theme.of(context).textTheme.bodyLarge,
              );
            }
            return Column(
              children: docs
                  .map((d) => _VerificationCard(uid: d.id, data: d.data()))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _VerificationCard extends StatefulWidget {
  const _VerificationCard({required this.uid, required this.data});
  final String uid;
  final Map<String, dynamic> data;

  @override
  State<_VerificationCard> createState() => _VerificationCardState();
}

class _VerificationCardState extends State<_VerificationCard> {
  bool _loading = false;

  Future<void> _setStatus(String status) async {
    setState(() => _loading = true);
    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(widget.uid)
        .update({'verificationStatus': status});
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data['name'] as String? ?? 'Sin nombre';
    final email = widget.data['email'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15)),
                Text(email, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (_loading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            TextButton(
              onPressed: () => _setStatus('approved'),
              child: const Text(
                'Aprobar',
                style: TextStyle(color: LavifyColors.success),
              ),
            ),
            TextButton(
              onPressed: () => _setStatus('rejected'),
              child: const Text(
                'Rechazar',
                style: TextStyle(color: Color(0xFFFF6B6B)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentOrdersSection extends StatelessWidget {
  const _RecentOrdersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Órdenes recientes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .orderBy('createdAt', descending: true)
              .limit(20)
              .snapshots(),
          builder: (context, snapshot) {
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Text(
                'No hay órdenes aún.',
                style: Theme.of(context).textTheme.bodyLarge,
              );
            }
            return Column(
              children: docs.map((d) {
                final data = d.data();
                final status = data['status'] as String? ?? '';
                final email = data['customerEmail'] as String? ?? '';
                final pkg = (data['request'] as Map?)?['packageName'] as String? ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: LavifyTheme.surfaceColor(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: LavifyTheme.borderColor(context)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg.isNotEmpty ? pkg : 'Pedido',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: LavifyColors.primary.withAlpha(22),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: LavifyColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? LavifyTheme.textPrimaryColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withAlpha(18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withAlpha(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: accent,
                  fontSize: 22,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
