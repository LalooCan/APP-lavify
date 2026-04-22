enum BackendMode { mock, firestore }

class AppConfig {
  const AppConfig._();

  // Cambia esta linea para mover toda la app entre mocks y Firestore.
  // Antes de activar produccion, despliega firestore.rules con Firebase CLI.
  static const BackendMode backendMode = BackendMode.firestore;

  static BackendMode get ordersBackendMode => backendMode;

  static BackendMode get trackingBackendMode => backendMode;

  static bool get usesRemoteTrackingBackend =>
      trackingBackendMode == BackendMode.firestore;

  static bool get usesRemoteOrdersBackend =>
      ordersBackendMode == BackendMode.firestore;
}
