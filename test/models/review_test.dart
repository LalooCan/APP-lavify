import 'package:flutter_test/flutter_test.dart';
import 'package:lavify_app/models/review.dart';

void main() {
  group('Review', () {
    final now = DateTime(2025, 1, 15, 10, 0, 0);

    final review = Review(
      id: 'rev_001',
      orderId: 'order_001',
      clientId: 'client_uid',
      workerId: 'worker_uid',
      rating: 4,
      comment: 'Buen servicio',
      createdAt: now,
    );

    test('toMap contiene todos los campos requeridos', () {
      final map = review.toMap();
      expect(map['id'], 'rev_001');
      expect(map['orderId'], 'order_001');
      expect(map['clientId'], 'client_uid');
      expect(map['workerId'], 'worker_uid');
      expect(map['rating'], 4);
      expect(map['comment'], 'Buen servicio');
    });

    test('fromMap reconstruye la instancia correctamente', () {
      final restored = Review.fromMap(review.toMap());
      expect(restored.id, review.id);
      expect(restored.rating, review.rating);
      expect(restored.comment, review.comment);
      expect(restored.workerId, review.workerId);
    });

    test('fromMap tolera campos faltantes con defaults', () {
      final minimal = Review.fromMap({'id': 'x', 'orderId': 'o'});
      expect(minimal.rating, 5);
      expect(minimal.comment, '');
      expect(minimal.clientId, '');
    });

    test('rating round-trip preserva valor entre 1 y 5', () {
      for (var r = 1; r <= 5; r++) {
        final map = {'id': 'x', 'orderId': 'o', 'rating': r};
        expect(Review.fromMap(map).rating, r);
      }
    });
  });
}
