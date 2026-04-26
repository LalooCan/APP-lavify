import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/wash_models.dart';

WashOrder _order({
  OrderStatus status = OrderStatus.searching,
  String clientId = 'client-1',
  String customerEmail = 'client@lavify.app',
  String? workerId,
  String? workerEmail,
}) {
  return WashOrder(
    id: 'order-1',
    request: WashRequest(
      serviceType: 'mobile_car_wash',
      packageId: 'express',
      packageName: 'Express',
      vehicleTypeId: 'sedan',
      vehicleTypeName: 'Sedan',
      address: 'Av. Test 123',
      latitude: 19.4,
      longitude: -99.1,
      scheduleId: 'now',
      scheduleLabel: 'Disponible - Ahora mismo',
      notes: '',
      servicePrice: 99,
      travelFee: 20,
      totalPrice: 119,
      estimatedMinutes: 25,
      currency: 'MXN',
      status: RequestLifecycleStatus.confirmed,
      createdAt: DateTime.utc(2026),
    ),
    status: status,
    clientId: clientId,
    customerEmail: customerEmail,
    assignedWasherName: workerEmail == null ? 'Por asignar' : 'Worker',
    workerId: workerId,
    assignedWorkerEmail: workerEmail,
    assignedVehicleLabel: 'Unidad activa',
    createdAt: DateTime.utc(2026),
    etaMinutes: 20,
  );
}

void main() {
  group('WashOrderVisibilityX', () {
    test('cliente ve sus pedidos por uid o email', () {
      final order = _order();

      expect(order.isVisibleToClient(clientId: 'client-1'), isTrue);
      expect(order.isVisibleToClient(email: 'CLIENT@lavify.app'), isTrue);
      expect(order.isVisibleToClient(clientId: 'otro'), isFalse);
    });

    test('lavador ve pedidos searching sin asignacion', () {
      final order = _order(status: OrderStatus.searching);

      expect(order.isVisibleToWorker(workerId: 'worker-1'), isTrue);
      expect(order.isVisibleToWorker(email: 'worker@lavify.app'), isTrue);
    });

    test('lavador solo ve pedidos asignados a su uid o email', () {
      final order = _order(
        status: OrderStatus.assigned,
        workerId: 'worker-1',
        workerEmail: 'worker@lavify.app',
      );

      expect(order.isVisibleToWorker(workerId: 'worker-1'), isTrue);
      expect(order.isVisibleToWorker(email: 'WORKER@lavify.app'), isTrue);
      expect(order.isVisibleToWorker(workerId: 'worker-2'), isFalse);
    });
  });
}
