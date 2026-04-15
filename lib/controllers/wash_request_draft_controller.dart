import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/location_service.dart';
import '../services/profile_service.dart';

class WashRequestDraftController {
  WashRequestDraftController({
    LocationService locationService = const LocationService(),
    ProfileService? profileService,
    WashPackage? initialPackage,
  }) : _locationService = locationService,
       _profileService = profileService ?? ProfileService() {
    final initialLocation = _locationService.getDefaultLocation();
    selectedPackageNotifier = ValueNotifier<WashPackage>(
      initialPackage ?? washPackages.last,
    );
    selectedScheduleNotifier = ValueNotifier<ScheduleSlot>(scheduleSlots[1]);
    selectedVehicleNotifier = ValueNotifier<VehicleType>(vehicleTypes[1]);
    selectedLocationNotifier = ValueNotifier<ServiceLocation>(initialLocation);
    addressNotifier = ValueNotifier<String>('Av. Reforma 245, CDMX');
    notesNotifier = ValueNotifier<String>('');
    isLocationConfirmedNotifier = ValueNotifier<bool>(false);
    isResolvingLocationNotifier = ValueNotifier<bool>(false);
    locationMessageNotifier = ValueNotifier<String?>(null);
    locationResolutionNotifier = ValueNotifier<LocationResolution?>(null);
    addressController = TextEditingController(text: addressNotifier.value);
    notesController = TextEditingController(text: notesNotifier.value);
    syncInitialLocation();
  }

  final LocationService _locationService;
  final ProfileService _profileService;

  late final TextEditingController addressController;
  late final TextEditingController notesController;
  late final ValueNotifier<WashPackage> selectedPackageNotifier;
  late final ValueNotifier<ScheduleSlot> selectedScheduleNotifier;
  late final ValueNotifier<VehicleType> selectedVehicleNotifier;
  late final ValueNotifier<ServiceLocation> selectedLocationNotifier;
  late final ValueNotifier<String> addressNotifier;
  late final ValueNotifier<String> notesNotifier;
  late final ValueNotifier<bool> isLocationConfirmedNotifier;
  late final ValueNotifier<bool> isResolvingLocationNotifier;
  late final ValueNotifier<String?> locationMessageNotifier;
  late final ValueNotifier<LocationResolution?> locationResolutionNotifier;

  int _resolutionRequestId = 0;

  Listenable get summaryListenable => Listenable.merge([
    selectedPackageNotifier,
    selectedScheduleNotifier,
    selectedVehicleNotifier,
    selectedLocationNotifier,
    addressNotifier,
    notesNotifier,
    isLocationConfirmedNotifier,
  ]);

  WashRequestDraft get draft => WashRequestDraft(
    selectedPackage: selectedPackageNotifier.value,
    address: addressNotifier.value,
    selectedSchedule: selectedScheduleNotifier.value,
    selectedVehicle: selectedVehicleNotifier.value,
    estimatedMinutes: 45,
    travelFee: 20,
    notes: notesNotifier.value,
    selectedLocation: selectedLocationNotifier.value,
    isLocationConfirmed: isLocationConfirmedNotifier.value,
  );

  void syncInitialLocation() {
    resolveLocation(selectedLocationNotifier.value, updateAddressField: true);
  }

  void selectPackage(WashPackage package) {
    selectedPackageNotifier.value = package;
  }

  void selectSchedule(ScheduleSlot slot) {
    selectedScheduleNotifier.value = slot;
  }

  void selectVehicle(VehicleType vehicle) {
    selectedVehicleNotifier.value = vehicle;
  }

  void updateAddress(String value) {
    addressNotifier.value = value;
    isLocationConfirmedNotifier.value = false;
    locationResolutionNotifier.value = LocationResolution(
      location: selectedLocationNotifier.value,
      address: value.trim().isEmpty
          ? selectedLocationNotifier.value.coordinatesLabel
          : value,
      source: LocationAddressSource.manual,
      isPrecise: false,
    );
    locationMessageNotifier.value = null;
  }

  void updateNotes(String value) {
    notesNotifier.value = value;
  }

  void updateLocation(ServiceLocation location) {
    selectedLocationNotifier.value = location;
    isLocationConfirmedNotifier.value = false;
    locationResolutionNotifier.value = LocationResolution(
      location: location,
      address: location.coordinatesLabel,
      source: LocationAddressSource.fallback,
      isPrecise: false,
    );
    locationMessageNotifier.value = null;
    resolveLocation(location, updateAddressField: true);
  }

  String? confirmLocation() {
    final resolvedAddress = addressController.text.trim();
    if (resolvedAddress.isEmpty) {
      return 'Selecciona o escribe una direccion antes de confirmarla.';
    }

    addressNotifier.value = resolvedAddress;
    _profileService.syncFavoriteAddress(resolvedAddress);
    isLocationConfirmedNotifier.value = true;
    locationResolutionNotifier.value = LocationResolution(
      location: selectedLocationNotifier.value,
      address: resolvedAddress,
      source: LocationAddressSource.manual,
      isPrecise: locationResolutionNotifier.value?.isPrecise ?? false,
    );
    locationMessageNotifier.value =
        'Ubicacion confirmada y lista para enviarse al backend.';
    return null;
  }

  Future<void> resolveLocation(
    ServiceLocation location, {
    required bool updateAddressField,
  }) async {
    final requestId = ++_resolutionRequestId;
    isResolvingLocationNotifier.value = true;

    final resolution = await _locationService.reverseGeocode(location);
    if (requestId != _resolutionRequestId ||
        selectedLocationNotifier.value != location) {
      return;
    }

    isResolvingLocationNotifier.value = false;
    locationResolutionNotifier.value = resolution;
    final resolvedAddress = resolution.address.trim();
    if (updateAddressField && resolvedAddress.isNotEmpty) {
      addressController.value = addressController.value.copyWith(
        text: resolvedAddress,
        selection: TextSelection.collapsed(offset: resolvedAddress.length),
        composing: TextRange.empty,
      );
      addressNotifier.value = resolvedAddress;
    }
    locationMessageNotifier.value = resolution.hasError
        ? resolution.errorMessage
        : null;
  }

  void dispose() {
    addressController.dispose();
    notesController.dispose();
    selectedPackageNotifier.dispose();
    selectedScheduleNotifier.dispose();
    selectedVehicleNotifier.dispose();
    selectedLocationNotifier.dispose();
    addressNotifier.dispose();
    notesNotifier.dispose();
    isLocationConfirmedNotifier.dispose();
    isResolvingLocationNotifier.dispose();
    locationMessageNotifier.dispose();
    locationResolutionNotifier.dispose();
  }
}
