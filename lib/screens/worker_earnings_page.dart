import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/order_service.dart';
import '../theme/theme.dart';

class WorkerEarningsPage extends StatefulWidget {
  const WorkerEarningsPage({super.key});

  @override
  State<WorkerEarningsPage> createState() => _WorkerEarningsPageState();
}

class _WorkerEarningsPageState extends State<WorkerEarningsPage> {
  static final OrderService _orderService = OrderService();
  String _period = 'today';

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<WashOrder>>(
      valueListenable: _orderService.orders,
      builder: (context, orders, _) {
        final completed = orders
            .where((o) => o.status == OrderStatus.completed)
            .toList();
        final data = _periodData(_period, completed);

        return Scaffold(
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Ganancias',
                    style: TextStyle(
                      color: LavifyTheme.textPrimaryColor(context),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu progreso financiero',
                    style: TextStyle(
                      color: LavifyTheme.textSecondaryColor(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PeriodSelector(
                    period: _period,
                    onChanged: (p) => setState(() => _period = p),
                  ),
                  const SizedBox(height: 20),
                  _EarningsHeroCard(data: data),
                  const SizedBox(height: 18),
                  _TrendChart(data: data),
                  const SizedBox(height: 14),
                  _StatsGrid(data: data),
                  const SizedBox(height: 18),
                  _WithdrawButton(total: data.total),
                  const SizedBox(height: 22),
                  Text(
                    'LAVADOS RECIENTES',
                    style: TextStyle(
                      color: LavifyTheme.textSecondaryColor(context),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _RecentWashes(orders: completed.take(4).toList()),
                ],
              ),
            ),
          ),
        ),
      ),
        );
      },
    );
  }
}

class _PeriodData {
  const _PeriodData({
    required this.total,
    required this.jobs,
    required this.tips,
    required this.hours,
    required this.goal,
    required this.prev,
    required this.bars,
    required this.barLabels,
  });
  final int total;
  final int jobs;
  final int tips;
  final String hours;
  final int goal;
  final int prev;
  final List<double> bars;
  final List<String> barLabels;
}

_PeriodData _periodData(String period, List<WashOrder> completed) {
  switch (period) {
    case 'week':
      return const _PeriodData(
        total: 2840, jobs: 23, tips: 410, hours: '32h',
        goal: 3500, prev: 2610,
        bars: [0.50, 0.80, 0.65, 0.95, 1.0, 0.75, 0.90],
        barLabels: ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
      );
    case 'month':
      return const _PeriodData(
        total: 11240, jobs: 92, tips: 1640, hours: '128h',
        goal: 14000, prev: 10120,
        bars: [0.60, 0.75, 0.90, 1.0],
        barLabels: ['S1', 'S2', 'S3', 'S4'],
      );
    default:
      return const _PeriodData(
        total: 487, jobs: 4, tips: 80, hours: '5h 20m',
        goal: 600, prev: 412,
        bars: [0.40, 0.75, 0.95, 0.60, 1.0, 0.85, 0.70],
        barLabels: ['8h', '10h', '12h', '14h', '16h', '18h', '20h'],
      );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.period, required this.onChanged});
  final String period;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = [('today', 'Hoy'), ('week', 'Semana'), ('month', 'Mes')];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        children: options.map(((String k, String l) opt) {
          final selected = period == opt.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? LavifyTheme.surfaceAltColor(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(38),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  opt.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? LavifyTheme.textPrimaryColor(context)
                        : LavifyTheme.textSecondaryColor(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EarningsHeroCard extends StatelessWidget {
  const _EarningsHeroCard({required this.data});
  final _PeriodData data;

  @override
  Widget build(BuildContext context) {
    final progress = (data.total / data.goal).clamp(0.0, 1.0);
    final growthPct =
        ((data.total - data.prev) / data.prev * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LavifyColors.primaryStrong, LavifyColors.primary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: LavifyColors.primaryGlow,
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL GANADO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\$${_fmt(data.total)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.4,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '↑ $growthPct%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'vs período anterior',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Meta: \$${_fmt(data.goal)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withAlpha(50),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({required this.data});
  final _PeriodData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencia',
            style: TextStyle(
              color: LavifyTheme.textPrimaryColor(context),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.bars.asMap().entries.map((entry) {
                final i = entry.key;
                final h = entry.value;
                final isLast = i == data.bars.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FractionallySizedBox(
                                  heightFactor: h,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isLast
                                          ? LavifyColors.primary
                                          : LavifyTheme.borderColor(
                                              context,
                                            ).withAlpha(100),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                        bottom: Radius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          data.barLabels[i],
                          style: TextStyle(
                            color: LavifyTheme.textSecondaryColor(context),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.data});
  final _PeriodData data;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('${data.jobs}', 'Lavados', LavifyTheme.textPrimaryColor(context)),
      ('\$${data.tips}', 'Propinas', LavifyColors.warning),
      (data.hours, 'En línea', LavifyColors.primary),
    ];
    return Row(
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final (v, l, c) = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: LavifyTheme.surfaceColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: LavifyTheme.borderColor(context)),
              ),
              child: Column(
                children: [
                  Text(
                    v,
                    style: TextStyle(
                      color: c,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l,
                    style: TextStyle(
                      color: LavifyTheme.textSecondaryColor(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WithdrawButton extends StatelessWidget {
  const _WithdrawButton({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    final isLight = LavifyTheme.isLight(context);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(
          Icons.account_balance_rounded,
          size: 18,
          color: isLight ? Colors.white : LavifyColors.background,
        ),
        label: Text(
          'Retirar \$${_fmt(total)} a mi banco',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isLight ? Colors.white : LavifyColors.background,
          ),
        ),
      ),
    );
  }
}

class _RecentWashes extends StatelessWidget {
  const _RecentWashes({required this.orders});
  final List<WashOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: LavifyTheme.surfaceColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: LavifyTheme.borderColor(context)),
        ),
        child: Text(
          'Aún no tienes lavados completados.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LavifyTheme.textSecondaryColor(context),
            fontSize: 14,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        children: orders.asMap().entries.map((entry) {
          final i = entry.key;
          final o = entry.value;
          final earned = (o.request.totalPrice * 0.85).round();
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              border: i < orders.length - 1
                  ? Border(
                      bottom: BorderSide(
                        color: LavifyTheme.borderColor(context),
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: LavifyColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_car_wash_rounded,
                    size: 15,
                    color: LavifyColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${o.request.packageName} · ${o.customerEmail.split('@').first}',
                        style: TextStyle(
                          color: LavifyTheme.textPrimaryColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        o.request.scheduleLabel,
                        style: TextStyle(
                          color: LavifyTheme.textSecondaryColor(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+\$$earned',
                  style: const TextStyle(
                    color: LavifyColors.success,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

String _fmt(int n) {
  if (n >= 1000) {
    return '${(n / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
  }
  return '$n';
}
