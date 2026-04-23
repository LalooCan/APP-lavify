import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/wash_models.dart';
import 'package:lavify_app/repositories/mock_order_repository.dart';

WashOrder _newOrder(String id) {
  return WashOrder(
    id: id,
    request: WashRequest(
      serviceType: 'mobile_car_wash',
      packageId: 'express',
      packageName: 'Express',
      vehicleTypeId: 'sedan',
      vehicleTypeName: 'Sedan',
      address: 'Test 1',
      latitude: 19.4,
      longitude: -99.1,
      scheduleId: 'now',
      scheduleLabel: 'now',
      notes: '',
      servicePrice: 99,
      travelFee: 10,
      totalPrice: 109,
      estimatedMinutes: 20,
      currency: 'MXN',
      status: RequestLifecycleStatus.confirmed,
      createdAt: DateTime.now().toUtc(),
    ),
    status: OrderStatus.searching,
    clientId: 'c1',
    customerEmail: 'a@b.com',
    assignedWasherName: 'Sin asignar',
    assignedVehicleLabel: 'Por definir',
    createdAt: DateTime.now(),
    etaMinutes: 20,
  );
}

void main() {
  group('MockOrderRepository', () {
    test('getOrders devuelve una lista inmutable', () {
      final repo = MockOrderRepository();
      final orders = repo.getOrders();
      expect(() => orders.add(_newOrder('x')), throwsUnsupportedError);
    });

    test('arranca con las fixtures seed', () {
      final repo = MockOrderRepository();
      expect(repo.getOrders(), isNotEmpty);
    });

    test('createOrder agrega al inicio y notifica el stream', () async {
      final repo = MockOrderRepository();
      final initial = repo.getOrders().length;
      final futureLengths = repo
          .watchOrders()
          .take(2)
          .map((list) => list.length)
          .toList();
      await Future<void>.delayed(Duration.zero);
      await repo.createOrder(_newOrder('NEW-1'));
      final lengths = await futureLengths;
      expect(lengths.first, initial);
      expect(lengths.last, initial + 1);
      expect(repo.getOrders().first.id, 'NEW-1');
    });

    test('updateOrder reemplaza el pedido existente', () async {
      final repo = MockOrderRepository();
      final order = _newOrder('UP-1');
      await repo.createOrder(order);
      final advanced = order.copyWith(status: OrderStatus.assigned);
      repo.updateOrder(advanced);
      final stored =
          repo.getOrders().firstWhere((item) => item.id == 'UP-1');
      expect(stored.status, OrderStatus.assigned);
    });

    test('updateOrder inserta cuando el id es nuevo', () {
      final repo = MockOrderRepository();
      final initial = repo.getOrders().length;
      repo.updateOrder(_newOrder('NEW-XYZ'));
      expect(repo.getOrders().length, initial + 1);
    });
  });
}
