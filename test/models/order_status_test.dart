import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/wash_models.dart';

void main() {
  group('OrderStatusX', () {
    test('apiValue ↔ fromValue round-trip por cada estado', () {
      for (final status in OrderStatus.values) {
        expect(OrderStatusX.fromValue(status.apiValue), status);
      }
    });

    test('fromValue cae a searching ante valores desconocidos', () {
      expect(OrderStatusX.fromValue('foo'), OrderStatus.searching);
    });

    test('isActiveForWorker marca solo los estados intermedios', () {
      expect(OrderStatus.searching.isActiveForWorker, isFalse);
      expect(OrderStatus.assigned.isActiveForWorker, isTrue);
      expect(OrderStatus.onTheWay.isActiveForWorker, isTrue);
      expect(OrderStatus.arrived.isActiveForWorker, isTrue);
      expect(OrderStatus.inProgress.isActiveForWorker, isTrue);
      expect(OrderStatus.completed.isActiveForWorker, isFalse);
    });

    test('nextForWorker respeta transiciones del lavador', () {
      expect(OrderStatus.searching.nextForWorker, isNull);
      expect(OrderStatus.assigned.nextForWorker, OrderStatus.onTheWay);
      expect(OrderStatus.onTheWay.nextForWorker, OrderStatus.arrived);
      expect(OrderStatus.arrived.nextForWorker, OrderStatus.inProgress);
      expect(OrderStatus.inProgress.nextForWorker, OrderStatus.completed);
      expect(OrderStatus.completed.nextForWorker, isNull);
    });

    test('label en espanol para cada estado', () {
      expect(OrderStatus.searching.label, 'Buscando lavador');
      expect(OrderStatus.completed.label, 'Completado');
    });
  });

  group('RequestLifecycleStatusX', () {
    test('apiValue ↔ fromValue round-trip', () {
      for (final status in RequestLifecycleStatus.values) {
        expect(RequestLifecycleStatusX.fromValue(status.apiValue), status);
      }
    });

    test('fromValue cae a draft ante valores desconocidos', () {
      expect(
        RequestLifecycleStatusX.fromValue('???'),
        RequestLifecycleStatus.draft,
      );
    });
  });
}
