import 'dart:async';

import '../models/wash_models.dart';
import 'mock_order_fixtures.dart';
import 'order_repository.dart';

class MockOrderRepository implements OrderRepository {
  MockOrderRepository() {
    _orders.addAll(MockOrderFixtures.initialOrders());
  }

  final List<WashOrder> _orders = <WashOrder>[];
  final StreamController<List<WashOrder>> _controller =
      StreamController<List<WashOrder>>.broadcast();

  @override
  Stream<List<WashOrder>> watchOrders() async* {
    yield getOrders();
    yield* _controller.stream;
  }

  @override
  List<WashOrder> getOrders() => List<WashOrder>.unmodifiable(_orders);

  @override
  Future<WashOrder> createOrder(WashOrder order) async {
    _orders.insert(0, order);
    _controller.add(getOrders());
    return order;
  }

  @override
  Future<WashOrder> updateOrder(WashOrder order) async {
    final index = _orders.indexWhere((item) => item.id == order.id);
    if (index >= 0) {
      _orders[index] = order;
    } else {
      _orders.insert(0, order);
    }
    _controller.add(getOrders());
    return order;
  }
}
