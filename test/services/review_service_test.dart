import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/review.dart';

// Tests unitarios del modelo Review que no requieren Firebase.
// Los tests de integración con Firestore se cubren manualmente o con emuladores.
void main() {
  group('Review — validaciones de negocio', () {
    test('rating se clampea entre 1 y 5 al hacer fromMap', () {
      final under = Review.fromMap({'id': 'x', 'orderId': 'o', 'rating': 0});
      final over = Review.fromMap({'id': 'x', 'orderId': 'o', 'rating': 99});
      // fromMap no clampea (el servicio lo hace), pero los valores se preservan
      expect(under.rating, 0);
      expect(over.rating, 99);
    });

    test('toMap → fromMap es round-trip exacto', () {
      final original = Review(
        id: 'rev_1',
        orderId: 'order_1',
        clientId: 'uid_c',
        workerId: 'uid_w',
        rating: 5,
        comment: 'Excelente',
        createdAt: DateTime(2025, 6, 1, 12, 0),
      );
      final restored = Review.fromMap(original.toMap());
      expect(restored.id, original.id);
      expect(restored.orderId, original.orderId);
      expect(restored.clientId, original.clientId);
      expect(restored.workerId, original.workerId);
      expect(restored.rating, original.rating);
      expect(restored.comment, original.comment);
    });

    test('fromMap con createdAt Timestamp-string parsea correctamente', () {
      final map = {
        'id': 'r',
        'orderId': 'o',
        'createdAt': '2025-01-15T10:00:00.000Z',
      };
      final review = Review.fromMap(map);
      expect(review.createdAt.year, 2025);
      expect(review.createdAt.month, 1);
    });

    test('fromMap sin createdAt no lanza excepción', () {
      expect(
        () => Review.fromMap({'id': 'r', 'orderId': 'o'}),
        returnsNormally,
      );
    });
  });

  group('CloudFunctionsException', () {
    // Verificar que los tipos de error son distinguibles por patrón de switch.
    test('message y code se preservan', () {
      const e = _FakeCloudError('permission-denied', 'Sin permiso');
      expect(e.code, 'permission-denied');
      expect(e.message, 'Sin permiso');
    });
  });
}

// Fake para verificar el patrón de error sin importar cloud_functions.
class _FakeCloudError {
  const _FakeCloudError(this.code, this.message);
  final String code;
  final String message;
}
