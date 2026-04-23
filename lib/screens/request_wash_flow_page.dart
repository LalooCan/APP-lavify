import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/wash_request_draft_controller.dart';
import '../models/wash_models.dart';
import '../theme/theme.dart';
import 'order_confirmation_page.dart';

class RequestWashFlowPage extends StatefulWidget {
  const RequestWashFlowPage({super.key, this.initialPackage});

  final WashPackage? initialPackage;

  @override
  State<RequestWashFlowPage> createState() => _RequestWashFlowPageState();
}

class _RequestWashFlowPageState extends State<RequestWashFlowPage> {
  late final WashRequestDraftController _controller;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _controller = WashRequestDraftController(
      initialPackage: widget.initialPackage ?? washPackages[1],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LavifyColors.background,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.7, -1.0),
            radius: 1.2,
            colors: [Color(0x2A3D7BFF), LavifyColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  _RequestHeader(
                    step: _step,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _RequestStepBody(
                        key: ValueKey<int>(_step),
                        step: _step,
                        controller: _controller,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller.summaryListenable,
                    builder: (context, _) {
                      return _RequestBottomBar(
                        step: _step,
                        total: _controller.draft.totalPrice,
                        onBack: _step == 0
                            ? null
                            : () => setState(() => _step -= 1),
                        onContinue: _handleContinue,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      final error = _controller.confirmLocation();
      if (error != null) {
        _showMessage(error);
        return;
      }
      setState(() => _step = 2);
      return;
    }

    final validationMessage = _controller.draft.validationMessage;
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderConfirmationPage(draft: _controller.draft),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _RequestHeader extends StatelessWidget {
  const _RequestHeader({required this.step, required this.onClose});

  final int step;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: LavifyColors.border)),
      ),
      child: Row(
        children: [
          _SurfaceIconButton(icon: Icons.close_rounded, onTap: onClose),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pedir lavado',
                  style: TextStyle(
                    color: LavifyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Paso ${step + 1} de 3',
                  style: const TextStyle(
                    color: LavifyColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(3, (index) {
              final active = index == step;
              final filled = index <= step;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: active ? 28 : 8,
                height: 8,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 5),
                decoration: BoxDecoration(
                  color: filled ? LavifyColors.primary : LavifyColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RequestStepBody extends StatelessWidget {
  const _RequestStepBody({
    super.key,
    required this.step,
    required this.controller,
  });

  final int step;
  final WashRequestDraftController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
      child: switch (step) {
        0 => _PackageStep(controller: controller),
        1 => _LocationVehicleStep(controller: controller),
        _ => _ScheduleSummaryStep(controller: controller),
      },
    );
  }
}

class _PackageStep extends StatelessWidget {
  const _PackageStep({required this.controller});

  final WashRequestDraftController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WashPackage>(
      valueListenable: controller.selectedPackageNotifier,
      builder: (context, selectedPackage, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeading(
              title: 'Elige tu paquete',
              subtitle: 'Selecciona el nivel de limpieza que necesitas',
            ),
            const SizedBox(height: 20),
            for (final package in washPackages) ...[
              _PackageTile(
                package: package,
                selected: package.id == selectedPackage.id,
                onTap: () => controller.selectPackage(package),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _LocationVehicleStep extends StatelessWidget {
  const _LocationVehicleStep({required this.controller});

  final WashRequestDraftController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller.selectedLocationNotifier,
        controller.selectedVehicleNotifier,
        controller.addressNotifier,
        controller.locationMessageNotifier,
        controller.locationResolutionNotifier,
        controller.isLocationConfirmedNotifier,
        controller.isResolvingLocationNotifier,
      ]),
      builder: (context, _) {
        final selectedVehicle = controller.selectedVehicleNotifier.value;
        final address = controller.addressController.text.trim().isEmpty
            ? controller.addressNotifier.value
            : controller.addressController.text.trim();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeading(
              title: 'Confirma ubicacion',
              subtitle: 'Donde esta tu auto ahora mismo',
            ),
            const SizedBox(height: 18),
            _RadarLocationCard(
              address: address,
              location: controller.selectedLocationNotifier.value,
              isResolving: controller.isResolvingLocationNotifier.value,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller.addressController,
              onChanged: controller.updateAddress,
              style: const TextStyle(
                color: LavifyColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              decoration: _flowInputDecoration(
                hintText: 'Direccion del servicio',
              ),
            ),
            const SizedBox(height: 20),
            const _SectionLabel('Tipo de vehiculo'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehicleTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.34,
              ),
              itemBuilder: (context, index) {
                final vehicle = vehicleTypes[index];
                return _VehicleTile(
                  vehicle: vehicle,
                  selected: vehicle.id == selectedVehicle.id,
                  onTap: () => controller.selectVehicle(vehicle),
                );
              },
            ),
            const SizedBox(height: 18),
            _InlineHint(
              icon: controller.isLocationConfirmedNotifier.value
                  ? Icons.verified_rounded
                  : Icons.info_outline_rounded,
              color: controller.isLocationConfirmedNotifier.value
                  ? LavifyColors.success
                  : LavifyColors.primary,
              text:
                  controller.locationMessageNotifier.value ??
                  'Al continuar, la direccion queda confirmada para tu pedido.',
            ),
          ],
        );
      },
    );
  }
}

class _ScheduleSummaryStep extends StatelessWidget {
  const _ScheduleSummaryStep({required this.controller});

  final WashRequestDraftController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.summaryListenable,
      builder: (context, _) {
        final selectedSchedule = controller.selectedScheduleNotifier.value;
        final draft = controller.draft;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepHeading(
              title: 'Horario y resumen',
              subtitle: 'Confirma cuando quieres tu lavado',
            ),
            const SizedBox(height: 18),
            for (final slot in _preferredSchedules()) ...[
              _ScheduleTile(
                slot: slot,
                selected: slot.id == selectedSchedule.id,
                onTap: () => controller.selectSchedule(slot),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            _SummaryCard(draft: draft),
          ],
        );
      },
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final WashPackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0x171A68FF) : LavifyColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? LavifyColors.primary : LavifyColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (package.id == 'full-care')
              Positioned(
                top: -18,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LavifyColors.primaryStrong,
                        LavifyColors.primary,
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'MAS POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          color: LavifyColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        package.description,
                        style: const TextStyle(
                          color: LavifyColors.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: LavifyColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _packageDuration(package.id),
                            style: const TextStyle(
                              color: LavifyColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package.formattedPrice,
                      style: TextStyle(
                        color: selected
                            ? LavifyColors.primary
                            : LavifyColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: LavifyColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  const _VehicleTile({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final VehicleType vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final extraFee = _vehicleExtraFee(vehicle.id);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0x146AA8FF) : LavifyColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? LavifyColors.primary : LavifyColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              vehicle.icon,
              size: 22,
              color: selected
                  ? LavifyColors.primary
                  : LavifyColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              vehicle.name.replaceAll(' mediano', ''),
              style: TextStyle(
                color: selected
                    ? LavifyColors.textPrimary
                    : LavifyColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (extraFee > 0) ...[
              const SizedBox(height: 2),
              Text(
                '+\$$extraFee',
                style: const TextStyle(
                  color: LavifyColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final ScheduleSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0x146AA8FF) : LavifyColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? LavifyColors.primary : LavifyColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0x1A6AA8FF)
                    : Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                Icons.schedule_rounded,
                size: 18,
                color: selected
                    ? LavifyColors.primary
                    : LavifyColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _scheduleTitle(slot.id, slot.time),
                    style: const TextStyle(
                      color: LavifyColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _scheduleSubtitle(slot.id, slot.period),
                    style: const TextStyle(
                      color: LavifyColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_rounded,
                size: 16,
                color: LavifyColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.draft});

  final WashRequestDraft draft;

  @override
  Widget build(BuildContext context) {
    final extraFee = _vehicleExtraFee(draft.selectedVehicle.id);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LavifyColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LavifyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del pedido',
            style: TextStyle(
              color: LavifyColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...[
            ('Paquete', draft.selectedPackage.name),
            ('Vehiculo', draft.selectedVehicle.name.replaceAll(' mediano', '')),
            (
              'Horario',
              _scheduleTitle(
                draft.selectedSchedule.id,
                draft.selectedSchedule.time,
              ),
            ),
            ('Direccion', draft.address),
          ].map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 78,
                    child: Text(
                      row.$1,
                      style: const TextStyle(
                        color: LavifyColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: LavifyColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: LavifyColors.border, height: 1),
          ),
          const SizedBox(height: 12),
          Text(
            '${draft.selectedPackage.name} · ${draft.selectedPackage.formattedPrice}',
            style: const TextStyle(
              color: LavifyColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Desplazamiento · \$20',
            style: TextStyle(color: LavifyColors.textSecondary, fontSize: 12),
          ),
          if (extraFee > 0) ...[
            const SizedBox(height: 6),
            Text(
              '${draft.selectedVehicle.name.replaceAll(' mediano', '')} extra · +\$$extraFee',
              style: const TextStyle(
                color: LavifyColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: LavifyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '\$${draft.totalPrice + extraFee}',
                style: const TextStyle(
                  color: LavifyColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadarLocationCard extends StatefulWidget {
  const _RadarLocationCard({
    required this.address,
    required this.location,
    required this.isResolving,
  });

  final String address;
  final ServiceLocation location;
  final bool isResolving;

  @override
  State<_RadarLocationCard> createState() => _RadarLocationCardState();
}

class _RadarLocationCardState extends State<_RadarLocationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.address.trim().isEmpty
        ? 'Av. Reforma 245'
        : widget.address.trim();
    return Container(
      height: 176,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1422),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _PulseRing(progress: _controller.value),
                  _PulseRing(progress: (_controller.value + 0.35) % 1),
                ],
              );
            },
          ),
          const Icon(
            Icons.location_on_rounded,
            size: 36,
            color: LavifyColors.primary,
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 210),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: LavifyColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: LavifyColors.border),
              ),
              child: Text(
                widget.isResolving ? 'Resolviendo...' : address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: LavifyColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = 70 + (progress * 90);
    return Opacity(
      opacity: (1 - progress) * 0.45,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0x446AA8FF)),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x126AA8FF)
      ..strokeWidth = 1;
    for (double y = 35; y < size.height; y += 35) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 45; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final pathPaint = Paint()
      ..color = const Color(0x336AA8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.55,
        size.width * 0.58,
        size.height * 0.48,
      )
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.40,
        size.width * 0.84,
        size.height * 0.28,
      );
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RequestBottomBar extends StatelessWidget {
  const _RequestBottomBar({
    required this.step,
    required this.total,
    required this.onBack,
    required this.onContinue,
  });

  final int step;
  final int total;
  final VoidCallback? onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final extra = step == 1
        ? _vehicleExtraFee(
            (context
                    .findAncestorStateOfType<_RequestWashFlowPageState>()
                    ?._controller
                    .selectedVehicleNotifier
                    .value
                    .id) ??
                '',
          )
        : 0;
    final label = step < 2 ? 'Continuar' : 'Confirmar · \$${total + extra}';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: LavifyColors.border)),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            _SurfaceIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack!,
              large: true,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: InkWell(
              onTap: onContinue,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [LavifyColors.primaryStrong, LavifyColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x403D7BFF),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      step < 2
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: LavifyColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: LavifyColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: LavifyColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _InlineHint extends StatelessWidget {
  const _InlineHint({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SurfaceIconButton extends StatelessWidget {
  const _SurfaceIconButton({
    required this.icon,
    required this.onTap,
    this.large = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 50.0 : 40.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(large ? 15 : 13),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: LavifyColors.surface,
          borderRadius: BorderRadius.circular(large ? 15 : 13),
          border: Border.all(color: LavifyColors.border),
        ),
        child: Icon(
          icon,
          size: large ? 20 : 18,
          color: LavifyColors.textPrimary,
        ),
      ),
    );
  }
}

InputDecoration _flowInputDecoration({required String hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF4A5A72), fontSize: 14),
    filled: true,
    fillColor: LavifyColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: LavifyColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: LavifyColors.primary),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: LavifyColors.border),
    ),
  );
}

List<ScheduleSlot> _preferredSchedules() {
  const preferred = ['now', 'today_630', 'tomorrow_900'];
  return preferred
      .map(
        (id) => scheduleSlots.firstWhere(
          (slot) => slot.id == id,
          orElse: () => scheduleSlots.first,
        ),
      )
      .toList(growable: false);
}

String _packageDuration(String packageId) {
  switch (packageId) {
    case 'express':
      return '30-45 min';
    case 'full-care':
      return '60-90 min';
    case 'premium':
      return '90-120 min';
    default:
      return '45 min';
  }
}

String _scheduleTitle(String scheduleId, String fallback) {
  switch (scheduleId) {
    case 'now':
      return 'Ahora mismo';
    case 'today_630':
      return 'Hoy por la tarde';
    case 'tomorrow_900':
      return 'Manana por la manana';
    default:
      return fallback;
  }
}

String _scheduleSubtitle(String scheduleId, String fallback) {
  switch (scheduleId) {
    case 'now':
      return '20-30 min de llegada';
    case 'today_630':
      return '18:30 - 20:00';
    case 'tomorrow_900':
      return '09:00 - 12:00';
    default:
      return fallback;
  }
}

int _vehicleExtraFee(String vehicleId) {
  switch (vehicleId) {
    case 'suv':
      return 30;
    case 'truck':
      return 50;
    default:
      return 0;
  }
}
