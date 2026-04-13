import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/section_text.dart';
import 'request_wash_flow_page.dart';

@Deprecated('Usa RequestWashFlowPage')
class RequestWashPage extends StatelessWidget {
  const RequestWashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RequestWashFlowPage();
  }
}

class RequestWashLegacyPage extends StatefulWidget {
  const RequestWashLegacyPage({super.key});

  @override
  State<RequestWashLegacyPage> createState() => _RequestWashLegacyPageState();
}

class _RequestWashLegacyPageState extends State<RequestWashLegacyPage> {
  late WashRequestDraft draft;

  @override
  void initState() {
    super.initState();
    draft = WashRequestDraft(
      selectedPackage: washPackages.last,
      address: 'Av. Reforma 245, CDMX',
      scheduleLabel: 'Hoy · 6:30 PM',
      estimatedMinutes: 45,
      travelFee: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;

    return Scaffold(
      appBar: AppBar(title: const Text('Pedir lavado')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1423),
              Color(0xFF0E1B30),
              LavifyColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 56 : 20,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionText(
                  title: 'Reserva tu lavado',
                  highlight: 'en minutos',
                  subtitle:
                      'Preparamos una experiencia clara para elegir tu servicio, confirmar ubicacion y dejar lista la integracion con mapa y backend.',
                ),
                const SizedBox(height: 28),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: _BookingDetails(
                          draft: draft,
                          onPackageSelected: _handlePackageSelected,
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(flex: 5, child: _BookingSummary(draft: draft)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _BookingDetails(
                        draft: draft,
                        onPackageSelected: _handlePackageSelected,
                      ),
                      SizedBox(height: 20),
                      _BookingSummary(draft: draft),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePackageSelected(WashPackage package) {
    setState(() {
      draft = draft.copyWith(selectedPackage: package);
    });
  }
}

class _BookingDetails extends StatelessWidget {
  const _BookingDetails({required this.draft, required this.onPackageSelected});

  final WashRequestDraft draft;
  final ValueChanged<WashPackage> onPackageSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepCard(
          step: '01',
          title: 'Elige tu paquete',
          child: _PackageSelector(
            selectedPackage: draft.selectedPackage,
            onPackageSelected: onPackageSelected,
          ),
        ),
        const SizedBox(height: 18),
        const _StepCard(
          step: '02',
          title: 'Confirma la ubicacion',
          child: _LocationSection(),
        ),
        const SizedBox(height: 18),
        const _StepCard(
          step: '03',
          title: 'Selecciona horario',
          child: _ScheduleSection(),
        ),
      ],
    );
  }
}

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({required this.draft});

  final WashRequestDraft draft;

  @override
  Widget build(BuildContext context) {
    final package = draft.selectedPackage;
    final total = package.price + draft.travelFee;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: LavifyColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: LavifyColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 22,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [
                          LavifyColors.primaryStrong,
                          LavifyColors.primary,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.local_car_wash_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Resumen del pedido',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SummaryRow(label: 'Paquete', value: package.summary),
              const SizedBox(height: 10),
              _SummaryRow(label: 'Direccion', value: draft.address),
              const SizedBox(height: 10),
              _SummaryRow(label: 'Horario', value: draft.scheduleLabel),
              const SizedBox(height: 10),
              _SummaryRow(
                label: 'Tiempo estimado',
                value: '${draft.estimatedMinutes} min',
              ),
              const SizedBox(height: 18),
              const Divider(color: LavifyColors.border),
              const SizedBox(height: 16),
              _PriceLine(
                label: package.priceLabel,
                value: package.formattedPrice,
                highlight: false,
              ),
              const SizedBox(height: 10),
              _PriceLine(
                label: 'Tarifa por desplazamiento',
                value: '\$${draft.travelFee}',
                highlight: false,
              ),
              const SizedBox(height: 10),
              _PriceLine(
                label: 'Total estimado',
                value: '\$$total',
                highlight: true,
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Confirmar lavado · \$$total',
                onPressed: () {},
                isExpanded: true,
              ),
              const SizedBox(height: 14),
              SecondaryButton(
                label: 'Volver al inicio',
                onPressed: () => Navigator.of(context).pop(),
                icon: Icons.arrow_back_rounded,
                isExpanded: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0x66162845),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: LavifyColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0x1F28D17C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: LavifyColors.success,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Todos los lavadores pasan verificacion y calificacion continua.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LavifyColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.title,
    required this.child,
  });

  final String step;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LavifyColors.surface,
        borderRadius: BorderRadius.circular(28),
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
                  border: Border.all(color: LavifyColors.border),
                ),
                child: Text(
                  step,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LavifyColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _PackageSelector extends StatelessWidget {
  const _PackageSelector({
    required this.selectedPackage,
    required this.onPackageSelected,
  });

  final WashPackage selectedPackage;
  final ValueChanged<WashPackage> onPackageSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: washPackages
          .map(
            (package) => _PackageCard(
              package: package,
              selected: package.id == selectedPackage.id,
              onTap: () => onPackageSelected(package),
            ),
          )
          .toList(),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.onTap,
    this.selected = false,
  });

  final WashPackage package;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          width: 220,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: selected ? const Color(0x331D5FFF) : LavifyColors.surfaceAlt,
            border: Border.all(
              color: selected ? LavifyColors.primary : LavifyColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: selected
                          ? LavifyColors.primaryStrong
                          : Colors.white.withAlpha(10),
                    ),
                    child: Icon(
                      package.icon,
                      color: selected
                          ? LavifyColors.textPrimary
                          : LavifyColors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1F28D17C),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Seleccionado',
                        style: TextStyle(
                          color: LavifyColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                package.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 18),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: LavifyColors.surfaceAlt,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0x3322C1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: LavifyColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ubicacion del servicio',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LavifyColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Av. Paseo de la Reforma 245, Juarez, Ciudad de Mexico',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'La integracion con mapa ira aqui despues. Por ahora dejamos el bloque visual listo para autocompletado y geolocalizacion.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _InfoChip(
                icon: Icons.directions_car_filled_rounded,
                label: 'Sedan mediano',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _InfoChip(
                icon: Icons.timer_outlined,
                label: 'Llegada en 20 min',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SelectableSlot(
                title: 'Ahora mismo',
                subtitle: 'Disponible',
                selected: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SelectableSlot(title: '6:30 PM', subtitle: 'Hoy'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SelectableSlot(title: '8:00 PM', subtitle: 'Hoy'),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SelectableSlot(title: '9:00 AM', subtitle: 'Manana'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SelectableSlot(title: '11:30 AM', subtitle: 'Manana'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SelectableSlot(title: '2:00 PM', subtitle: 'Manana'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SelectableSlot extends StatelessWidget {
  const _SelectableSlot({
    required this.title,
    required this.subtitle,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: selected ? const Color(0x331D5FFF) : LavifyColors.surfaceAlt,
        border: Border.all(
          color: selected ? LavifyColors.primary : LavifyColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LavifyColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected
                  ? LavifyColors.primary
                  : LavifyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: LavifyColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: LavifyColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: LavifyColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({
    required this.label,
    required this.value,
    required this.highlight,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight
        ? LavifyColors.textPrimary
        : LavifyColors.textSecondary;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: highlight ? LavifyColors.primary : LavifyColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class WashRequestDraft {
  const WashRequestDraft({
    required this.selectedPackage,
    required this.address,
    required this.scheduleLabel,
    required this.estimatedMinutes,
    required this.travelFee,
  });

  final WashPackage selectedPackage;
  final String address;
  final String scheduleLabel;
  final int estimatedMinutes;
  final int travelFee;

  WashRequestDraft copyWith({
    WashPackage? selectedPackage,
    String? address,
    String? scheduleLabel,
    int? estimatedMinutes,
    int? travelFee,
  }) {
    return WashRequestDraft(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      address: address ?? this.address,
      scheduleLabel: scheduleLabel ?? this.scheduleLabel,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      travelFee: travelFee ?? this.travelFee,
    );
  }
}

class WashPackage {
  const WashPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.priceLabel,
    required this.summary,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;
  final int price;
  final String priceLabel;
  final String summary;
  final IconData icon;

  String get formattedPrice => '\$$price';
}

const List<WashPackage> washPackages = [
  WashPackage(
    id: 'express',
    name: 'Express',
    description: 'Lavado exterior rapido para mantener tu auto impecable.',
    price: 99,
    priceLabel: 'Lavado express',
    summary: 'Express exterior',
    icon: Icons.flash_on_rounded,
  ),
  WashPackage(
    id: 'full-care',
    name: 'Full Care',
    description: 'Exterior e interior con enfoque en limpieza detallada.',
    price: 149,
    priceLabel: 'Lavado full care',
    summary: 'Full Care interior + exterior',
    icon: Icons.cleaning_services_rounded,
  ),
  WashPackage(
    id: 'premium',
    name: 'Premium',
    description: 'Acabado profundo, brillo y sanitizacion completa.',
    price: 199,
    priceLabel: 'Lavado premium',
    summary: 'Premium interior + exterior',
    icon: Icons.auto_awesome_rounded,
  ),
];
