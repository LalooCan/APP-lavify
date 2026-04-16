import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../controllers/wash_request_draft_controller.dart';
import '../models/wash_models.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/section_text.dart';
import '../widgets/section_container.dart';
import 'order_confirmation_page.dart';

class RequestWashFlowPage extends StatefulWidget {
  const RequestWashFlowPage({super.key, this.initialPackage});

  final WashPackage? initialPackage;

  @override
  State<RequestWashFlowPage> createState() => _RequestWashFlowPageState();
}

class _RequestWashFlowPageState extends State<RequestWashFlowPage> {
  late final WashRequestDraftController _draftController;
  static const bool _isSubmitting = false;

  WashRequestDraft get draft => _draftController.draft;

  @override
  void initState() {
    super.initState();
    _draftController = WashRequestDraftController(
      initialPackage: widget.initialPackage,
    );
  }

  @override
  void dispose() {
    _draftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;

    return Scaffold(
      appBar: AppBar(title: const Text('Pedir lavado')),
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
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
                      'La seleccion del usuario ya se guarda en un draft local para luego enviarla a backend como una orden real.',
                ),
                const SizedBox(height: 28),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
                        child: _BookingDetails(
                          addressController: _draftController.addressController,
                          notesController: _draftController.notesController,
                          selectedPackageListenable:
                              _draftController.selectedPackageNotifier,
                          selectedScheduleListenable:
                              _draftController.selectedScheduleNotifier,
                          selectedVehicleListenable:
                              _draftController.selectedVehicleNotifier,
                          selectedLocationListenable:
                              _draftController.selectedLocationNotifier,
                          addressListenable: _draftController.addressNotifier,
                          isLocationConfirmedListenable:
                              _draftController.isLocationConfirmedNotifier,
                          isResolvingLocationListenable:
                              _draftController.isResolvingLocationNotifier,
                          locationMessageListenable:
                              _draftController.locationMessageNotifier,
                          locationResolutionListenable:
                              _draftController.locationResolutionNotifier,
                          onPackageSelected: _draftController.selectPackage,
                          onScheduleSelected: _draftController.selectSchedule,
                          onVehicleSelected: _draftController.selectVehicle,
                          onAddressChanged: _draftController.updateAddress,
                          onNotesChanged: _draftController.updateNotes,
                          onLocationChanged: _draftController.updateLocation,
                          onConfirmLocation: _handleLocationConfirmation,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 5,
                        child: AnimatedBuilder(
                          animation: _draftController.summaryListenable,
                          builder: (context, _) {
                            return _BookingSummary(
                              draft: draft,
                              onConfirm: _handleConfirm,
                              isSubmitting: _isSubmitting,
                            );
                          },
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _BookingDetails(
                        addressController: _draftController.addressController,
                        notesController: _draftController.notesController,
                        selectedPackageListenable:
                            _draftController.selectedPackageNotifier,
                        selectedScheduleListenable:
                            _draftController.selectedScheduleNotifier,
                        selectedVehicleListenable:
                            _draftController.selectedVehicleNotifier,
                        selectedLocationListenable:
                            _draftController.selectedLocationNotifier,
                        addressListenable: _draftController.addressNotifier,
                        isLocationConfirmedListenable:
                            _draftController.isLocationConfirmedNotifier,
                        isResolvingLocationListenable:
                            _draftController.isResolvingLocationNotifier,
                        locationMessageListenable:
                            _draftController.locationMessageNotifier,
                        locationResolutionListenable:
                            _draftController.locationResolutionNotifier,
                        onPackageSelected: _draftController.selectPackage,
                        onScheduleSelected: _draftController.selectSchedule,
                        onVehicleSelected: _draftController.selectVehicle,
                        onAddressChanged: _draftController.updateAddress,
                        onNotesChanged: _draftController.updateNotes,
                        onLocationChanged: _draftController.updateLocation,
                        onConfirmLocation: _handleLocationConfirmation,
                      ),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _draftController.summaryListenable,
                        builder: (context, _) {
                          return _BookingSummary(
                            draft: draft,
                            onConfirm: _handleConfirm,
                            isSubmitting: _isSubmitting,
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLocationConfirmation() {
    final validationMessage = _draftController.confirmLocation();
    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }
  }

  void _handleConfirm() {
    if (_isSubmitting) {
      return;
    }

    final validationMessage = draft.validationMessage;
    if (validationMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(validationMessage)));
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrderConfirmationPage(draft: draft),
      ),
    );
  }
}

class _BookingDetails extends StatelessWidget {
  const _BookingDetails({
    required this.addressController,
    required this.notesController,
    required this.selectedPackageListenable,
    required this.selectedScheduleListenable,
    required this.selectedVehicleListenable,
    required this.selectedLocationListenable,
    required this.addressListenable,
    required this.isLocationConfirmedListenable,
    required this.isResolvingLocationListenable,
    required this.locationMessageListenable,
    required this.locationResolutionListenable,
    required this.onPackageSelected,
    required this.onScheduleSelected,
    required this.onVehicleSelected,
    required this.onAddressChanged,
    required this.onNotesChanged,
    required this.onLocationChanged,
    required this.onConfirmLocation,
  });

  final TextEditingController addressController;
  final TextEditingController notesController;
  final ValueNotifier<WashPackage> selectedPackageListenable;
  final ValueNotifier<ScheduleSlot> selectedScheduleListenable;
  final ValueNotifier<VehicleType> selectedVehicleListenable;
  final ValueNotifier<ServiceLocation> selectedLocationListenable;
  final ValueNotifier<String> addressListenable;
  final ValueNotifier<bool> isLocationConfirmedListenable;
  final ValueNotifier<bool> isResolvingLocationListenable;
  final ValueNotifier<String?> locationMessageListenable;
  final ValueNotifier<LocationResolution?> locationResolutionListenable;
  final ValueChanged<WashPackage> onPackageSelected;
  final ValueChanged<ScheduleSlot> onScheduleSelected;
  final ValueChanged<VehicleType> onVehicleSelected;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<ServiceLocation> onLocationChanged;
  final VoidCallback onConfirmLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepCard(
          step: '01',
          title: 'Elige tu paquete',
          child: ValueListenableBuilder<WashPackage>(
            valueListenable: selectedPackageListenable,
            builder: (context, selectedPackage, _) {
              return _PackageSelector(
                selectedPackage: selectedPackage,
                onPackageSelected: onPackageSelected,
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        _StepCard(
          step: '02',
          title: 'Confirma la ubicacion y tu vehiculo',
          child: Column(
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([
                  selectedLocationListenable,
                  addressListenable,
                  isLocationConfirmedListenable,
                  isResolvingLocationListenable,
                  locationMessageListenable,
                  locationResolutionListenable,
                ]),
                builder: (context, _) {
                  return _LocationSelectionPanel(
                    addressController: addressController,
                    onAddressChanged: onAddressChanged,
                    selectedLocation: selectedLocationListenable.value,
                    onLocationChanged: onLocationChanged,
                    onConfirmLocation: onConfirmLocation,
                    isResolvingLocation: isResolvingLocationListenable.value,
                    locationMessage: locationMessageListenable.value,
                    locationResolution: locationResolutionListenable.value,
                    isLocationConfirmed: isLocationConfirmedListenable.value,
                  );
                },
              ),
              const SizedBox(height: 18),
              ValueListenableBuilder<VehicleType>(
                valueListenable: selectedVehicleListenable,
                builder: (context, selectedVehicle, _) {
                  return _VehicleSelectionSection(
                    selectedVehicle: selectedVehicle,
                    onVehicleSelected: onVehicleSelected,
                  );
                },
              ),
              const SizedBox(height: 14),
              TextField(
                controller: notesController,
                onChanged: onNotesChanged,
                maxLines: 3,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: LavifyTheme.textPrimaryColor(context),
                ),
                decoration: _inputDecoration(
                  context: context,
                  label: 'Notas para el lavador',
                  hint:
                      'Ej. Tocar timbre, entrar por porton azul, agua disponible.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _StepCard(
          step: '03',
          title: 'Selecciona horario',
          child: ValueListenableBuilder<ScheduleSlot>(
            valueListenable: selectedScheduleListenable,
            builder: (context, selectedSchedule, _) {
              return _ScheduleSection(
                selectedSchedule: selectedSchedule,
                onScheduleSelected: onScheduleSelected,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({
    required this.draft,
    required this.onConfirm,
    required this.isSubmitting,
  });

  final WashRequestDraft draft;
  final VoidCallback onConfirm;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final package = draft.selectedPackage;
    final total = package.price + draft.travelFee;
    final canContinueToConfirmation = draft.isReadyForConfirmation;

    return RepaintBoundary(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: LavifyTheme.surfaceColor(context),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: LavifyTheme.borderColor(context)),
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
                _SummaryRow(
                  label: 'Coordenadas',
                  value:
                      '${draft.selectedLocation.latitude.toStringAsFixed(6)}, ${draft.selectedLocation.longitude.toStringAsFixed(6)}',
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Vehiculo',
                  value: draft.selectedVehicle.name,
                ),
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Horario',
                  value: draft.selectedSchedule.label,
                ),
                if (draft.notes.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _SummaryRow(label: 'Notas', value: draft.notes.trim()),
                ],
                const SizedBox(height: 10),
                _SummaryRow(
                  label: 'Tiempo estimado',
                  value: '${draft.estimatedMinutes} min',
                ),
                const SizedBox(height: 18),
                Divider(color: LavifyTheme.borderColor(context)),
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
                  label: isSubmitting
                      ? 'Preparando resumen...'
                      : 'Continuar a confirmacion - \$$total',
                  onPressed: canContinueToConfirmation ? onConfirm : null,
                  isExpanded: true,
                ),
                if (!canContinueToConfirmation) ...[
                  const SizedBox(height: 10),
                  Text(
                    draft.hasValidAddress
                        ? 'Confirma la ubicacion del servicio para continuar.'
                        : 'Selecciona una direccion y confirma la ubicacion para continuar.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFFC857),
                    ),
                  ),
                ],
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
        ],
      ),
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
    return SectionContainer(
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
                  color: LavifyTheme.softFillColor(context),
                  border: Border.all(color: LavifyTheme.borderColor(context)),
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
    required this.selected,
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
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Color(0x1222C1FF)),
        child: Ink(
          width: 220,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: selected
                ? LavifyTheme.selectedTileColor(context)
                : LavifyTheme.surfaceAltColor(context),
            border: Border.all(
              color: selected
                  ? LavifyColors.primary
                  : LavifyTheme.borderColor(context),
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
                          : LavifyTheme.softFillColor(context),
                    ),
                    child: Icon(
                      package.icon,
                      color: selected ? Colors.white : LavifyColors.primary,
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

class _LocationSelectionPanel extends StatelessWidget {
  const _LocationSelectionPanel({
    required this.addressController,
    required this.onAddressChanged,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.onConfirmLocation,
    required this.isResolvingLocation,
    required this.locationMessage,
    required this.locationResolution,
    required this.isLocationConfirmed,
  });

  final TextEditingController addressController;
  final ValueChanged<String> onAddressChanged;
  final ServiceLocation selectedLocation;
  final ValueChanged<ServiceLocation> onLocationChanged;
  final VoidCallback onConfirmLocation;
  final bool isResolvingLocation;
  final String? locationMessage;
  final LocationResolution? locationResolution;
  final bool isLocationConfirmed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: LavifyTheme.surfaceAltColor(context),
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
                        color: LavifyTheme.textPrimaryColor(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Edita la direccion real del servicio para dejar el pedido listo para backend.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: addressController,
          onChanged: onAddressChanged,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: LavifyTheme.textPrimaryColor(context),
          ),
          decoration: _inputDecoration(
            context: context,
            label: 'Direccion del servicio',
            hint: 'Ej. Av. Paseo de la Reforma 245, Juarez, CDMX',
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 280,
            width: double.infinity,
            child: _ServiceLocationMap(
              selectedLocation: selectedLocation,
              onLocationChanged: onLocationChanged,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LavifyTheme.softFillStrongColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: LavifyTheme.borderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Ubicacion seleccionada',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LavifyTheme.textPrimaryColor(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (isResolvingLocation)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (isLocationConfirmed)
                    const Icon(
                      Icons.verified_rounded,
                      color: LavifyColors.success,
                      size: 18,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                (locationResolution?.address ?? addressController.text)
                        .trim()
                        .isEmpty
                    ? 'Aun no hay direccion seleccionada'
                    : (locationResolution?.address ?? addressController.text),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: LavifyTheme.textPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Coordenadas: ${selectedLocation.coordinatesLabel}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                locationMessage ??
                    'Toca o arrastra el pin para fijar la ubicacion exacta del servicio.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: locationMessage == null
                      ? LavifyTheme.textSecondaryColor(context)
                      : isLocationConfirmed
                      ? LavifyColors.success
                      : const Color(0xFFFFC857),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: isResolvingLocation
              ? 'Resolviendo direccion...'
              : isLocationConfirmed
              ? 'Ubicacion confirmada'
              : 'Confirmar ubicacion',
          onPressed: isResolvingLocation ? null : onConfirmLocation,
          isExpanded: true,
        ),
      ],
    );
  }
}

class _VehicleSelectionSection extends StatelessWidget {
  const _VehicleSelectionSection({
    required this.selectedVehicle,
    required this.onVehicleSelected,
  });

  final VehicleType selectedVehicle;
  final ValueChanged<VehicleType> onVehicleSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Tipo de vehiculo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: LavifyTheme.textPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: vehicleTypes
              .map(
                (vehicle) => _VehicleChip(
                  vehicle: vehicle,
                  selected: vehicle.id == selectedVehicle.id,
                  onTap: () => onVehicleSelected(vehicle),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.selectedSchedule,
    required this.onScheduleSelected,
  });

  final ScheduleSlot selectedSchedule;
  final ValueChanged<ScheduleSlot> onScheduleSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: scheduleSlots
          .map(
            (slot) => _SelectableSlot(
              title: slot.time,
              subtitle: slot.period,
              selected: slot.id == selectedSchedule.id,
              onTap: () => onScheduleSelected(slot),
            ),
          )
          .toList(),
    );
  }
}

class _SelectableSlot extends StatelessWidget {
  const _SelectableSlot({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Color(0x1222C1FF)),
        child: Ink(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: selected
                ? LavifyTheme.selectedTileColor(context)
                : LavifyTheme.surfaceAltColor(context),
            border: Border.all(
              color: selected
                  ? LavifyColors.primary
                  : LavifyTheme.borderColor(context),
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: LavifyTheme.textPrimaryColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? LavifyColors.primary
                      : LavifyTheme.textSecondaryColor(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final VehicleType vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Color(0x1222C1FF)),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? LavifyTheme.selectedTileColor(context)
                : LavifyTheme.selectedTileSoftColor(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? LavifyColors.primary
                  : LavifyTheme.borderColor(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(vehicle.icon, color: LavifyColors.primary, size: 18),
              const SizedBox(width: 10),
              Text(
                vehicle.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LavifyTheme.textPrimaryColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceLocationMap extends StatefulWidget {
  const _ServiceLocationMap({
    required this.selectedLocation,
    required this.onLocationChanged,
  });

  final ServiceLocation selectedLocation;
  final ValueChanged<ServiceLocation> onLocationChanged;

  @override
  State<_ServiceLocationMap> createState() => _ServiceLocationMapState();
}

class _ServiceLocationMapState extends State<_ServiceLocationMap> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final latLng = widget.selectedLocation.toLatLng();

    return RepaintBoundary(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: latLng, zoom: 14),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: (position) {
          widget.onLocationChanged(
            ServiceLocation(
              latitude: position.latitude,
              longitude: position.longitude,
            ),
          );
        },
        markers: {
          Marker(
            markerId: const MarkerId('service_location'),
            position: latLng,
            draggable: true,
            onDragEnd: (position) {
              widget.onLocationChanged(
                ServiceLocation(
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
              );
            },
          ),
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _ServiceLocationMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedLocation != widget.selectedLocation) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(widget.selectedLocation.toLatLng()),
      );
    }
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
            color: LavifyTheme.textPrimaryColor(context),
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
        ? LavifyTheme.textPrimaryColor(context)
        : LavifyTheme.textSecondaryColor(context);

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
            color: highlight
                ? LavifyColors.primary
                : LavifyTheme.textPrimaryColor(context),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

InputDecoration _inputDecoration({
  required BuildContext context,
  required String label,
  required String hint,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    labelStyle: TextStyle(color: LavifyTheme.textSecondaryColor(context)),
    hintStyle: TextStyle(color: LavifyTheme.textSecondaryColor(context)),
    filled: true,
    fillColor: LavifyTheme.surfaceAltColor(context),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: LavifyTheme.borderColor(context)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: LavifyTheme.borderColor(context)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: LavifyColors.primary),
    ),
  );
}
