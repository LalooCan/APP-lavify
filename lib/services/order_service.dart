import 'package:flutter/foundation.dart';

import '../models/wash_models.dart';

class OrderService {
  OrderService._internal();

  static final OrderService _instance = OrderService._internal();

  factory OrderService() => _instance;

  final ValueNotifier<List<WashOrder>> orders = ValueNotifier<List<WashOrder>>([
    WashOrder(
      id: 'LAV-1001',
      request: WashRequest(
        serviceType: 'mobile_car_wash',
        packageId: 'premium',
        packageName: 'Premium',
        vehicleTypeId: 'sedan',
        vehicleTypeName: 'Sedan mediano',
        address: 'Av. Reforma 245, CDMX',
        latitude: 19.432608,
        longitude: -99.133209,
        scheduleId: 'today_630',
        scheduleLabel: 'Hoy - 6:30 PM',
        notes: '',
        servicePrice: 199,
        travelFee: 20,
        totalPrice: 219,
        estimatedMinutes: 35,
        currency: 'MXN',
        status: 'assigned',
        createdAt: DateTime.now().toUtc(),
      ),
      status: OrderStatus.assigned,
      assignedWasherName: 'Carlos M.',
      assignedVehicleLabel: 'Unidad eco 07',
      createdAt: DateTime.now(),
      etaMinutes: 18,
    ),
    WashOrder(
      id: 'LAV-0998',
      request: WashRequest(
        serviceType: 'mobile_car_wash',
        packageId: 'full-care',
        packageName: 'Full Care',
        vehicleTypeId: 'compact',
        vehicleTypeName: 'Compacto',
        address: 'Polanco, CDMX',
        latitude: 19.433,
        longitude: -99.2,
        scheduleId: 'yesterday_1100',
        scheduleLabel: 'Ayer - 11:00 AM',
        notes: 'Llamar al llegar',
        servicePrice: 149,
        travelFee: 20,
        totalPrice: 169,
        estimatedMinutes: 40,
        currency: 'MXN',
        status: 'completed',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toUtc(),
      ),
      status: OrderStatus.completed,
      assignedWasherName: 'Andrea R.',
      assignedVehicleLabel: 'Unidad eco 03',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      etaMinutes: 0,
    ),
  ]);

  Future<WashOrder> createOrder(WashRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final order = WashOrder(
      id: 'LAV-${DateTime.now().millisecondsSinceEpoch}',
      request: request,
      status: OrderStatus.assigned,
      assignedWasherName: 'Carlos M.',
      assignedVehicleLabel: 'Unidad eco 07',
      createdAt: DateTime.now(),
      etaMinutes: request.estimatedMinutes,
    );

    orders.value = [order, ...orders.value];
    return order;
  }
}
