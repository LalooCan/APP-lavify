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
    final isLight = LavifyTheme.isLight(context);
    return Scaffold(
      backgroundColor: _flowBackgroundColor(context),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.75, -0.95),
            radius: 1.18,
            colors: isLight
                ? const [Color(0x24D6B47B), LavifyColors.lightBackground]
                : const [Color(0x183D7BFF), LavifyColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                children: [
                  _RequestWashHeader(
                    step: _step,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          fit: StackFit.expand,
                          children: [...previousChildren, ?currentChild],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.035, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _RequestFlowBody(
                        key: ValueKey<int>(_step),
                        step: _step,
                        controller: _controller,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller.summaryListenable,
                    builder: (context, _) {
                      return _BottomContinueButton(
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

class _RequestWashHeader extends StatelessWidget {
  const _RequestWashHeader({required this.step, required this.onClose});

  final int step;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _flowBorderColor(context))),
      ),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.close_rounded,
            onTap: onClose,
            size: 40,
            radius: 13,
            iconSize: 18,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pedir lavado',
                  style: TextStyle(
                    color: _flowTextPrimaryColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paso ${step + 1} de 3',
                  style: TextStyle(
                    color: _flowTextSecondaryColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          _StepProgress(step: step),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final active = index == step;
        final filled = index <= step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.only(left: index == 0 ? 0 : 5),
          width: active ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: filled
                ? _flowAccentColor(context)
                : _flowBorderColor(context),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _RequestFlowBody extends StatelessWidget {
  const _RequestFlowBody({
    super.key,
    required this.step,
    required this.controller,
  });

  final int step;
  final WashRequestDraftController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
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
            const _RequestSectionTitle(
              title: 'Elige tu paquete',
              subtitle: 'Selecciona el nivel de limpieza que necesitas',
            ),
            const SizedBox(height: 18),
            ...washPackages.map(
              (package) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _PackageCard(
                  package: package,
                  selected: package.id == selectedPackage.id,
                  onTap: () => controller.selectPackage(package),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final WashPackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPopular = package.id == 'full-care';
    final textPrimary = _flowTextPrimaryColor(context);
    final textSecondary = _flowTextSecondaryColor(context);
    final accent = _flowAccentColor(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? null : _flowSurfaceColor(context),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: LavifyTheme.isLight(context)
                        ? const [Color(0x22314664), Color(0x18D6B47B)]
                        : const [Color(0x243D7BFF), Color(0x146AA8FF)],
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? accent : _flowBorderColor(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (isPopular)
                const Positioned(top: -1, right: 16, child: _PopularBadge()),
              Container(
                constraints: const BoxConstraints(minHeight: 124),
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package.name,
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            package.description,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _packageDuration(package.id),
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1,
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
                        Padding(
                          padding: EdgeInsets.only(top: isPopular ? 12 : 0),
                          child: Text(
                            package.formattedPrice,
                            style: TextStyle(
                              color: selected ? accent : textPrimary,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: selected ? 1 : 0,
                          child: const _SelectedCheck(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularBadge extends StatelessWidget {
  const _PopularBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LavifyColors.primaryStrong, LavifyColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: const Text(
        'MAS POPULAR',
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1.2,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SelectedCheck extends StatelessWidget {
  const _SelectedCheck();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: LavifyColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
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
            const _RequestSectionTitle(
              title: 'Confirma ubicacion',
              subtitle: 'Donde esta tu auto ahora mismo',
            ),
            const SizedBox(height: 14),
            _RadarLocationCard(
              address: address,
              location: controller.selectedLocationNotifier.value,
              isResolving: controller.isResolvingLocationNotifier.value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.addressController,
              onChanged: controller.updateAddress,
              style: TextStyle(
                color: _flowTextPrimaryColor(context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: _flowInputDecoration(
                context: context,
                hintText: 'Direccion del servicio',
              ),
            ),
            const SizedBox(height: 26),
            const _SectionLabel('Tipo de vehiculo'),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: vehicleTypes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
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
          ],
        );
      },
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
    final extraFee = vehicle.extraFee;
    final textPrimary = _flowTextPrimaryColor(context);
    final textSecondary = _flowTextSecondaryColor(context);
    final accent = _flowAccentColor(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? _flowSelectedColor(context)
                : _flowSurfaceColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accent : _flowBorderColor(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                vehicle.icon,
                size: 26,
                color: selected ? accent : textSecondary,
              ),
              const SizedBox(height: 10),
              Text(
                vehicle.name.replaceAll(' mediano', ''),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? textPrimary : textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (extraFee > 0) ...[
                const SizedBox(height: 3),
                Text(
                  '+\$$extraFee',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
            const _RequestSectionTitle(
              title: 'Horario y resumen',
              subtitle: 'Confirma cuando quieres tu lavado',
            ),
            const SizedBox(height: 18),
            ..._preferredSchedules().map(
              (slot) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ScheduleTile(
                  slot: slot,
                  selected: slot.id == selectedSchedule.id,
                  onTap: () => controller.selectSchedule(slot),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _SummaryCard(draft: draft),
          ],
        );
      },
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
    final textPrimary = _flowTextPrimaryColor(context);
    final textSecondary = _flowTextSecondaryColor(context);
    final accent = _flowAccentColor(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? _flowSelectedColor(context)
                : _flowSurfaceColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? accent : _flowBorderColor(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: selected
                      ? _flowSelectedIconFillColor(context)
                      : _flowSoftFillColor(context),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: selected ? accent : textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _scheduleTitle(slot.id, slot.time),
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _scheduleSubtitle(slot.id, slot.period),
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_rounded, size: 18, color: accent),
            ],
          ),
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
    final extraFee = draft.vehicleExtraFee;
    final total = draft.totalPrice;
    final textPrimary = _flowTextPrimaryColor(context);
    final textSecondary = _flowTextSecondaryColor(context);
    final accent = _flowAccentColor(context);

    const sep = '\u00B7';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _flowSurfaceColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _flowBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del pedido',
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
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
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.$1,
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Divider(color: _flowBorderColor(context), height: 1),
          ),
          const SizedBox(height: 12),
          Text(
            '${draft.selectedPackage.name} $sep ${draft.selectedPackage.formattedPrice}',
            style: TextStyle(color: textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            'Desplazamiento $sep \$20',
            style: TextStyle(color: textSecondary, fontSize: 13),
          ),
          if (extraFee > 0) ...[
            const SizedBox(height: 6),
            Text(
              '${draft.selectedVehicle.name.replaceAll(' mediano', '')} extra $sep +\$$extraFee',
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '\$$total',
                style: TextStyle(
                  color: accent,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
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
    final isLight = LavifyTheme.isLight(context);
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFFFBF7) : const Color(0xFF0A1422),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _flowBorderColor(context)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                gridColor: isLight
                    ? const Color(0x25314664)
                    : const Color(0x126AA8FF),
                pathColor: isLight
                    ? const Color(0x44314664)
                    : const Color(0x336AA8FF),
                dotColor: isLight
                    ? const Color(0x88314664)
                    : const Color(0x886AA8FF),
              ),
            ),
          ),
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
            size: 42,
            color: LavifyColors.primary,
          ),
          Positioned(
            right: 14,
            bottom: 14,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: _flowSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _flowBorderColor(context)),
                ),
                child: Text(
                  widget.isResolving ? 'Resolviendo...' : address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _flowTextPrimaryColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
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
  const _GridPainter({
    required this.gridColor,
    required this.pathColor,
    required this.dotColor,
  });

  final Color gridColor;
  final Color pathColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (double y = 35; y < size.height; y += 35) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 45; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final pathPaint = Paint()
      ..color = pathColor
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

    final dotPaint = Paint()..color = dotColor;
    for (int i = 0; i < 10; i++) {
      final dx = size.width * (0.14 + (i * 0.075));
      final dy = size.height * (0.66 - math.sin(i * 0.5) * 0.12);
      canvas.drawCircle(Offset(dx, dy), 1.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor ||
        oldDelegate.pathColor != pathColor ||
        oldDelegate.dotColor != dotColor;
  }
}

class _BottomContinueButton extends StatelessWidget {
  const _BottomContinueButton({
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
    final isConfirm = step >= 2;
    const sep = '\u00B7';
    final label = isConfirm ? 'Confirmar $sep \$$total' : 'Continuar';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      decoration: BoxDecoration(
        color: _flowBackgroundColor(context),
        border: Border(top: BorderSide(color: _flowBorderColor(context))),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            _RoundIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack!,
              size: 58,
              radius: 18,
              iconSize: 22,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _flowButtonGradientColors(context),
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D3D7BFF),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onContinue,
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 58,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isConfirm) ...[
                          const Icon(
                            Icons.check_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        if (!isConfirm) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.size = 42,
    this.radius = 15,
    this.iconSize = 18,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _flowSurfaceColor(context),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: _flowBorderColor(context)),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: _flowTextPrimaryColor(context),
          ),
        ),
      ),
    );
  }
}

class _RequestSectionTitle extends StatelessWidget {
  const _RequestSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: _flowTextPrimaryColor(context),
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.02,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: _flowTextSecondaryColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
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
      style: TextStyle(
        color: _flowTextSecondaryColor(context),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

Color _flowBackgroundColor(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color _flowSurfaceColor(BuildContext context) =>
    LavifyTheme.surfaceColor(context);

Color _flowBorderColor(BuildContext context) =>
    LavifyTheme.borderColor(context);

Color _flowTextPrimaryColor(BuildContext context) =>
    LavifyTheme.textPrimaryColor(context);

Color _flowTextSecondaryColor(BuildContext context) =>
    LavifyTheme.textSecondaryColor(context);

Color _flowAccentColor(BuildContext context) => LavifyTheme.isLight(context)
    ? LavifyColors.lightNavy
    : LavifyColors.primary;

Color _flowSelectedColor(BuildContext context) => LavifyTheme.isLight(context)
    ? const Color(0x18314664)
    : const Color(0x1A6AA8FF);

Color _flowSelectedIconFillColor(BuildContext context) =>
    LavifyTheme.isLight(context)
    ? const Color(0x1F314664)
    : const Color(0x266AA8FF);

Color _flowSoftFillColor(BuildContext context) => LavifyTheme.isLight(context)
    ? const Color(0xFFF4ECE1)
    : Colors.white.withAlpha(10);

List<Color> _flowButtonGradientColors(BuildContext context) =>
    LavifyTheme.isLight(context)
    ? const [LavifyColors.lightNavy, Color(0xFF4A6082)]
    : const [LavifyColors.primaryStrong, LavifyColors.primary];

InputDecoration _flowInputDecoration({
  required BuildContext context,
  required String hintText,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: _flowBorderColor(context)),
  );

  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: _flowTextSecondaryColor(context).withAlpha(170),
      fontSize: 15,
    ),
    filled: true,
    fillColor: _flowSurfaceColor(context),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: _flowAccentColor(context)),
    ),
    border: border,
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
