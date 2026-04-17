enum TrackingBackendMode { mock, firestore }

enum OrdersBackendMode { mock, firestore }

class AppConfig {
  const AppConfig._();

  // Cambia a `TrackingBackendMode.firestore` cuando quieras usar
  // Firestore como fuente real del tracking en vivo.
  static const TrackingBackendMode trackingBackendMode =
      TrackingBackendMode.mock;

  // Cambia a `OrdersBackendMode.firestore` cuando quieras usar
  // Firestore como fuente real de pedidos.
  static const OrdersBackendMode ordersBackendMode = OrdersBackendMode.mock;

  static bool get usesRemoteTrackingBackend =>
      trackingBackendMode == TrackingBackendMode.firestore;

  static bool get usesRemoteOrdersBackend =>
      ordersBackendMode == OrdersBackendMode.firestore;
}
