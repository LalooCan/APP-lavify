import '../models/wash_models.dart';
import '../services/session_service.dart';
import 'order_repository.dart';

class MockOrderRepository implements OrderRepository {
  final List<WashOrder> _orders = <WashOrder>[];

  @override
  List<WashOrder> getOrders() => List<WashOrder>.unmodifiable(_orders);

  @override
  WashOrder createOrderFromDraft(WashRequestDraft draft) {
    final request = draft.toRequest();
    final session = SessionService().currentSession.value;
    final order = WashOrder(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      request: request,
      status: OrderStatus.searching,
      customerEmail: session?.email ?? 'cliente@lavify.app',
      assignedWasherName: 'Por asignar',
      assignedWorkerEmail: null,
      assignedVehicleLabel: request.vehicleTypeName,
      createdAt: DateTime.now().toUtc(),
      etaMinutes: request.estimatedMinutes,
    );
    _orders.insert(0, order);
    return order;
  }

  @override
  WashOrder updateOrder(WashOrder order) {
    final index = _orders.indexWhere((item) => item.id == order.id);
    if (index >= 0) {
      _orders[index] = order;
    } else {
      _orders.insert(0, order);
    }
    return order;
  }
}
